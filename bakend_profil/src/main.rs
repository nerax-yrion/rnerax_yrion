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
use tokio::sync::RwLock; // Concurrence asynchrone pure
use tower_http::cors::{Any, CorsLayer};
use axum::http::Method;
use std::path::Path;

// 🪐 Connexion propre de tes fichiers et dossiers de modules
pub mod modeles;
pub mod securite;
pub mod routes; // Indique à Rust d'aller lire le dossier "routes" et son fichier "mod.rs"

use modeles::Profil;
use securite::LimiteurDeDebit;

const FICHIER_BDD: &str = "profil_bdd.json";

/// Structure de l'état global optimisé pour la haute concurrence
pub struct EtatGlobal {
    pub bdd: RwLock<Profil>,
    pub limiteur: LimiteurDeDebit,
}

pub type BaseDeDonnees = Arc<EtatGlobal>;

/// 🛠️ Fonction utilitaire pour sauvegarder l'état actuel sur le disque dur
pub async fn sauvegarder_profil(profil: &Profil) {
    if let Ok(json) = serde_json::to_string_pretty(profil) {
        if let Err(e) = tokio::fs::write(FICHIER_BDD, json).await {
            eprintln!("❌ [ERREUR BDD] Impossible de sauvegarder sur le disque : {}", e);
        }
    }
}

/// 🛡️ Barrière de Sécurité Réseau Globale
async fn intercepteur_securite(
    ConnectInfo(adresse): ConnectInfo<SocketAddr>,
    State(etat): State<BaseDeDonnees>,
    requete: axum::extract::Request,
    next: Next,
) -> Result<Response, StatusCode> {
    let ip = adresse.ip().to_string();
    
    // Sécurité : On clone l'IP pour la donner au limiteur
    let ip_copie = ip.clone();
    
    if !etat.limiteur.verifier_ip(ip_copie) {
        println!("⚠️  [SÉCURITÉ] IP suspecte ou flood bloqué : {}", ip);
        return Err(StatusCode::TOO_MANY_REQUESTS);
    }
    
    Ok(next.run(requete).await)
}

#[tokio::main]
async fn main() {
    // 💾 Système de Persistance : Chargement de la sauvegarde ou initialisation par défaut
    let profil_initial = if Path::new(FICHIER_BDD).exists() {
        match tokio::fs::read_to_string(FICHIER_BDD).await {
            Ok(contenu) => serde_json::from_str(&contenu).unwrap_or_else(|_| {
                println!("⚠️  [BDD] Fichier corrompu, réinitialisation par défaut.");
                generer_profil_defaut()
            }),
            Err(_) => generer_profil_defaut(),
        }
    } else {
        generer_profil_defaut()
    };
    
    let etat = Arc::new(EtatGlobal {
        bdd: RwLock::new(profil_initial),
        limiteur: LimiteurDeDebit::new(),
    });

    let cors = CorsLayer::new()
        .allow_methods([Method::GET, Method::POST])
        .allow_origin(Any);

    let application = Router::new()
        .route("/api/profil", get(obtenir_profil_global))
        // Chemins branchés sur l'arborescence de ton dossier routes
        .route("/api/profil/avatar/enregistrer", post(routes::enregistrement::ajouter_avatar))
        .route("/api/profil/modifier/textes", post(routes::mise_a_jour::actualiser_textes))
        .route("/api/profil/avatar/remplacer", post(routes::mise_a_jour::remplacer_avatar))
        // Application globale du middleware de sécurité
        .route_layer(middleware::from_fn_with_state(etat.clone(), intercepteur_securite))
        .layer(cors)
        .with_state(etat);

    let adresse = "0.0.0.0:8080";
    let ecouteur = tokio::net::TcpListener::bind(adresse).await.unwrap();
    println!("🚀 [PRODUCTION] Moteur Yrion ultra-sécurisé en ligne sur : http://{}", adresse);
    
    axum::serve(ecouteur, application.into_make_service_with_connect_info::<SocketAddr>()).await.unwrap();
}

fn generer_profil_defaut() -> Profil {
    Profil {
        pseudo: "Alexandre".to_string(),
        nom_utilisateur: "astronaute_du_974".to_string(),
        bio: "Explorateur de tribus • Code & Streetwear ⚡".to_string(),
        url_avatar: None,
        nb_publications: "142".to_string(),
        nb_abonnes: "1.2K".to_string(),
        nb_tribus: "8".to_string(),
    }
}

async fn obtenir_profil_global(
    State(etat): State<BaseDeDonnees>,
) -> axum::Json<Profil> {
    // Lecture asynchrone ultra-rapide sans bloquer le thread principal
    let profil = etat.bdd.read().await;
    axum::Json(profil.clone())
}

// mise a jour