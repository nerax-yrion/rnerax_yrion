use axum::{routing::{get, post}, Router, Json}; // 🔑 Ajout de 'get' et 'Json' pour la route d'accueil
use std::net::SocketAddr;
use std::sync::Arc; 
use sqlx::postgres::PgPoolOptions; 
use tower::ServiceBuilder;
use tower_governor::{governor::GovernorConfigBuilder, GovernorLayer};
use serde_json::{json, Value}; // 📦 Pour structurer la réponse JSON proprement

mod models;
mod id;
mod securite;
mod inscription;
mod connexion;

// 🎯 FONCTION D'ACCUEIL QUI AFFICHE TES INFOS PERSONNALISÉES
async fn page_accueil() -> Json<Value> {
    Json(json!({
        "Application": "Yrion Backend Forteresse",
        "backend":"backend connexion inscription et id",
        "Créateur": "Alan Mitha",
        "Version": "1.0.0-Prod",
        "Statut": "Opérationnel & Cyber-Sécurisé 🛡️"
    }))
}

#[tokio::main]
async fn main() {
    // 1. CHARGEMENT DU FICHIER .ENV (Extrait ta clé secrète DATABASE_URL)
    if let Err(e) = dotenvy::dotenv() {
        println!("⚠️  Note : Impossible de charger le fichier .env ({}), vérification des variables système.", e);
    }

    // Récupération de la variable d'environnement ou crash propre si elle manque
    let database_url = std::env::var("DATABASE_URL")
        .expect("❌ ERREUR CRITIQUE : La variable DATABASE_URL n'est pas configurée dans le fichier .env !");

    // 2. OUVERTURE DU TUNNEL ULTRA-SÉCURISÉ VERS LE CLOUD NEON
    println!("🔌 Connexion au coffre-fort cloud Neon en cours...");
    let pool_database = PgPoolOptions::new()
        .max_connections(50) 
        .connect(&database_url)
        .await
        .expect("❌ Impossible de se connecter à la base de données Neon. Vérifie ta clé dans le fichier .env !");

    // 🚀 3. L'AUTOMATISME PRO : Rust compare et injecte ton nouveau code SQL sur Neon
    println!("📦 Analyse du dossier 'migrations' et synchronisation avec Neon...");
    sqlx::migrate!("./migrations")
        .run(&pool_database)
        .await
        .expect("❌ Échec critique lors de la mise à jour automatique des tables SQL sur Neon.");
    
    println!("✅ LE COFFRE-FORT NEON EST À JOUR ET SÉCURISÉ !");

    // 4. PROTECTION ANTI-DDOS & FORCE BRUTE (Pare-feu applicatif par IP sécurisé par Arc)
    let config_anti_ddos = Arc::new(
        GovernorConfigBuilder::default()
            .per_second(1)
            .burst_size(5)
            .finish()
            .unwrap(),
    );

    // 5. CONSTRUCTION DES ROUTES D'YRION (On partage la connexion DB avec les modules)
    let app = Router::new()
        .route("/", get(page_accueil)) // ✨ LA VOILÀ ! Ta page d'accueil personnalisée
        .route("/api/auth/register", post(inscription::executer_inscription))
        .route("/api/auth/login", post(connexion::executer_connexion))
        .with_state(pool_database) 
        .layer(
            ServiceBuilder::new()
                .layer(GovernorLayer {
                    config: config_anti_ddos, 
                })
        );

    // 6. LANCEMENT DU SERVEUR SUR LE PORT 4000
    let adresse_serveur = SocketAddr::from(([0, 0, 0, 0], 4000));
    println!("🛡️  FORTERESSE CYBER-SÉCURISÉE YRION LANCÉE SUR LE PORT : {}", adresse_serveur);

    let listener = tokio::net::TcpListener::bind(&adresse_serveur).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}