use axum::{routing::{get, post}, Router, Json}; 
use std::net::SocketAddr;
use std::sync::Arc; 
use sqlx::postgres::PgPoolOptions; 
use tower::ServiceBuilder;
// 🔑 Ajout de SmartIpKeyExtractor pour extraire l'IP derrière le proxy de Render
use tower_governor::{governor::GovernorConfigBuilder, GovernorLayer, key_extractor::SmartIpKeyExtractor};
use serde_json::{json, Value}; 

mod models;
mod id;
mod securite;
mod inscription;
mod connexion;

// 🎯 FONCTION D'ACCUEIL QUI AFFICHE TES INFOS PERSONNALISÉES
async fn page_accueil() -> Json<Value> {
    Json(json!({
        "Application": "Yrion Backend Forteresse",
        "Créateur": "Alan Mitha",
        "Version": "1.0.0-Prod",
        "Statut": "Opérationnel & Cyber-Sécurisé 🛡️"
    }))
}

#[tokio::main]
async fn main() {
    // 1. CHARGEMENT DU FICHIER .ENV 
    if let Err(e) = dotenvy::dotenv() {
        println!("⚠️  Note : Impossible de charger le fichier .env ({}), vérification des variables système.", e);
    }

    let database_url = std::env::var("DATABASE_URL")
        .expect("❌ ERREUR CRITIQUE : La variable DATABASE_URL n'est pas configurée dans le fichier .env !");

    // 2. OUVERTURE DU TUNNEL VERS LE CLOUD NEON
    println!("🔌 Connexion au coffre-fort cloud Neon en cours...");
    let pool_database = PgPoolOptions::new()
        .max_connections(50) 
        .connect(&database_url)
        .await
        .expect("❌ Impossible de se connecter à la base de données Neon. Vérifie ta clé dans le fichier .env !");

    // 🚀 3. SYNCHRONISATION AVEC NEON
    println!("📦 Analyse du dossier 'migrations' et synchronisation avec Neon...");
    sqlx::migrate!("./migrations")
        .run(&pool_database)
        .await
        .expect("❌ Échec critique lors de la mise à jour automatique des tables SQL sur Neon.");
    
    println!("✅ LE COFFRE-FORT NEON EST À JOUR ET SÉCURISÉ !");

    // 4. PROTECTION ANTI-DDOS COMPATIBLE CLOUD / RENDER (Utilisation de SmartIpKeyExtractor)
    let config_anti_ddos = Arc::new(
        GovernorConfigBuilder::default()
            .per_second(1)
            .burst_size(5)
            .key_extractor(SmartIpKeyExtractor) // ✨ Indique au pare-feu de lire l'IP via le proxy Render !
            .finish()
            .unwrap(),
    );

    // 5. CONSTRUCTION DES ROUTES D'YRION 
    let app = Router::new()
        .route("/", get(page_accueil)) 
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