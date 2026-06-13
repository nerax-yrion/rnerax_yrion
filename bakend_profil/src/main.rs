use axum::{
    routing::{get, post},
    Router,
    extract::{State, ConnectInfo},
    http::StatusCode,
    middleware::{self, Next},
    response::Response,
};
use std::net::SocketAddr;
use std::sync::Arc;
use tokio::sync::RwLock; 
use tower_http::cors::{Any, CorsLayer};
use axum::http::Method;
use std::path::Path;

// 🪐 Connexion propre de tes fichiers et dossiers de modules
pub mod modeles;
pub mod securite;
pub mod routes; 

use modeles::{BaseDeDonneesGlobale, Utilisateur, Profil, MoteurDeStockageSecurise};
use securite::LimiteurDeDebit;

const FICHIER_BDD: &str = "profil_bdd.json";

/// Structure de l'état global configurée pour des milliards d'utilisateurs
pub struct EtatGlobal {
    // Changement critique : on stocke la BaseDeDonneesGlobale (HashMap) et non plus un seul profil
    pub bdd: RwLock<BaseDeDonneesGlobale>,
    pub limiteur: LimiteurDeDebit,
    pub moteur_stockage: MoteurDeStockageSecurise,
}

pub type BaseDeDonnees = Arc<EtatGlobal>;

/// 🛡️ Barrière de Sécurité Réseau Globale
async fn intercepteur_securite(
    ConnectInfo(adresse): ConnectInfo<SocketAddr>,
    State(etat): State<BaseDeDonnees>,
    requete: axum::extract::Request,
    next: Next,
) -> Result<Response, StatusCode> {
    let ip = adresse.ip().to_string();
    
    // Correction Bug Capture 3 : Ajout de .await sur la fonction asynchrone verifier_ip
    if !etat.limiteur.verifier_ip(&ip).await {
        println!("⚠️  [SÉCURITÉ] IP suspecte ou flood bloqué : {}", ip);
        return Err(StatusCode::TOO_MANY_REQUESTS);
    }
    
    Ok(next.run(requete).await)
}

#[tokio::main]
async fn main() {
    // Initialisation du moteur de stockage atomique permanent
    let moteur = MoteurDeStockageSecurise::new(FICHIER_BDD);

    // 💾 Système de Persistance : Chargement du JSON global ou initialisation à vide
    let bdd_initiale = if Path::new(FICHIER_BDD).exists() {
        match tokio::fs::read_to_string(FICHIER_BDD).await {
            Ok(contenu) => serde_json::from_str(&contenu).unwrap_or_else(|_| {
                println!("⚠️  [BDD] Fichier général corrompu, réinitialisation à vide.");
                BaseDeDonneesGlobale::default()
            }),
            Err(_) => BaseDeDonneesGlobale::default(),
        }
    } else {
        // Au premier démarrage, on crée une base propre
        let mut bdd_vide = BaseDeDonneesGlobale::default();
        // On injecte un compte de démonstration pour Alexandre
        let compte_alex = generer_compte_defaut();
        let _ = bdd_vide.inscrire_utilisateur(
            compte_alex.email.clone(),
            "MotDePasseSecurise123".to_string(), // Sera automatiquement haché par notre moteur
            compte_alex.profil.pseudo.clone(),
            compte_alex.profil.nom_utilisateur.clone()
        );
        bdd_vide
    };
    
    let etat = Arc::new(EtatGlobal {
        bdd: RwLock::new(bdd_initiale),
        limiteur: LimiteurDeDebit::new(),
        moteur_stockage: moteur,
    });

    let cors = CorsLayer::new()
        .allow_methods([Method::GET, Method::POST])
        .allow_origin(Any);

    let application = Router::new()
        .route("/api/utilisateurs", get(obtenir_tous_les_profils))
        // Chemins branchés sur l'arborescence de ton dossier routes
        .route("/api/auth/inscription", post(routes::enregistrement::inscrire_nouvel_utilisateur))
        .route("/api/profil/avatar/enregistrer", post(routes::enregistrement::ajouter_avatar))
        .route("/api/profil/modifier/textes", post(routes::mise_a_jour::actualiser_textes))
        .route("/api/profil/avatar/remplacer", post(routes::mise_a_jour::remplacer_avatar))
        // Application globale du middleware de sécurité
        .route_layer(middleware::from_fn_with_state(etat.clone(), intercepteur_securite))
        .layer(cors)
        .with_state(etat);

    let adresse = "0.0.0.0:8080";
    let ecouteur = tokio::net::TcpListener::bind(adresse).await.unwrap();
    println!("🚀 [PRODUCTION] Moteur Yrion mondial en ligne sur : http://{}", adresse);
    
    axum::serve(ecouteur, application.into_make_service_with_connect_info::<SocketAddr>()).await.unwrap();
}

/// Correction Bug Capture 4 : Reconstruction du compte par défaut alignée sur les types mondiaux
fn generer_compte_defaut() -> Utilisateur {
    Utilisateur {
        id: uuid::Uuid::new_v4().to_string(),
        email: "alexandre@yrion.com".to_string(),
        mot_de_passe_hache: "".to_string(), // Géré dynamiquement par inscrire_utilisateur
        cree_le: std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_secs(),
        profil: Profil {
            pseudo: "Alexandre".to_string(),
            nom_utilisateur: "astronaute_du_974".to_string(),
            bio: "Explorateur de tribus • Code & Streetwear ⚡".to_string(),
            url_avatar: None,
            nb_publications: 142, // Changé en u64 pur
            nb_abonnes: 1200,     // Changé en u64 pur
            nb_tribus: 8,         // Changé en u64 pur
            verifie: true,        // Badge certifié d'office pour le créateur !
        },
    }
}

/// Endpoint mondial : Renvoie la liste complète des comptes de la plateforme
async fn obtenir_tous_les_profils(
    State(etat): State<BaseDeDonnees>,
) -> axum::Json<BaseDeDonneesGlobale> {
    let bdd = etat.bdd.read().await;
    axum::Json(bdd.clone())
}

// mise a jour 1