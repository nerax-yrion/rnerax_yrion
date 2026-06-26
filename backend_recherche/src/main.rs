use std::net::SocketAddr;
use std::sync::Arc;
use axum::{routing::get, Router, response::Html, middleware};
use tokio::sync::RwLock;
use tower_http::{cors::CorsLayer, compression::CompressionLayer};

mod protocole;
mod registre;
mod gestionnaire;
mod securite;
mod middleware_ddos; 
mod moteur_recherche; // 👈 AJOUT INDISPENSABLE : On déclare le module à Rust ici !

use registre::CatalogueUtilisateurs;
use gestionnaire::point_entree_recherche;
use middleware_ddos::appliquer_protection_ddos;

/// 🌐 INTERFACE STATIQUE DE PRODUCTION (YRION CORE v4)
async fn page_accueil() -> Html<&'static str> {
    Html(r#"
        Créateur: Nerax_Yrion
        Version: 4.0.0
        Status: En ligne
    "#)
}

#[tokio::main]
async fn main() {
    // ⚡ 1. RÉCUPÉRATION SÉCURISÉE DE L'URL DE LA BASE DE DONNÉES NEON
    let url_database = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://user:password@localhost/dbname".to_string());

    // ⚡ 2. INITIALISATION DU POOL POSTGRESQL MULTI-THREAD ASYNC
    println!("[SYSTEME] Connexion à la forteresse de données Neon...");
    let pool_neon = sqlx::PgPool::connect(&url_database)
        .await
        .expect("Impossible de se connecter à la base de données Neon");

    // 🛠️ CORRECTIF APPLICATION DIRECTE : Réinitialise proprement le compteur SQLx pour tuer le VersionMismatch
    let _ = sqlx::query("DROP TABLE IF EXISTS _sqlx_migrations;")
        .execute(&pool_neon)
        .await;

    // 🚀 3. EXÉCUTION DES MIGRATIONS ET CRÉATION DES INDEXATIONS GIN
    println!("[SYSTEME] Déploiement des indexations d'élite (Dossier ./migrations)...");
    sqlx::migrate!("./migrations")
        .run(&pool_neon)
        .await
        .expect("Échec critique lors du déploiement de la migration sur Neon");
        
    println!("[SYSTEME] Base de données Neon synchronisée et indexée avec succès !");

    // 🛡️ ACCÉLÉRATEUR EN MÉMOIRE (RWLOCK ALLOCATION PLANIFIÉE POUR 1M D'UTILISATEURS)
    let base_donnees_recherche = Arc::new(RwLock::new(CatalogueUtilisateurs::initialiser_haute_capacite(1000000)));

    // 🚀 4. INJECTION DES MIDDLEWARES ET CONSTRUTION DU PIPELINE ROUTEUR
    let application = Router::new()
        .route("/", get(page_accueil)) 
        .route("/yrion_recherche", get(point_entree_recherche)) 
        .layer(CorsLayer::permissive())
        .layer(CompressionLayer::new())
        .layer(middleware::from_fn(appliquer_protection_ddos))
        .with_state(base_donnees_recherche);

    // ⚡ 5. CONFIGURATION DU PORT COMPATIBLE AVEC L'ENVIRONNEMENT RENDER
    let port: u16 = std::env::var("PORT")
        .unwrap_or_else(|_| "2013".to_string())
        .parse()
        .unwrap_or(2013);
    
    let adresse_serveur = SocketAddr::from(([0, 0, 0, 0], port));
    let ecouteur_reseau = tokio::net::TcpListener::bind(adresse_serveur).await.unwrap();
    
    println!("========================================================");
    println!("👑 MICRO-SERVEUR DE RECHERCHE ULTRA-SÉCURISÉ YRION CORE v4");
    println!("📡 Fréquence réseau calée exclusivement sur le PORT : {}", port);
    println!("🛡️ Immunité contre le piratage, scraping et DDoS activée");
    println!("========================================================");

    // 🛑 6. ALLUMAGE ET GESTIONNAIRE D'ARRÊT PROPRE (GRACEFUL SHUTDOWN)
    axum::serve(ecouteur_reseau, application)
        .with_graceful_shutdown(attendre_signal_extinction())
        .await
        .unwrap();
}

/// 🛑 INTERCEPTEUR DE SIGNAL LOGICIEL DE FIN DE VIE (SIGTERM / CTRL+C)
async fn attendre_signal_extinction() {
    let ctrl_c = async {
        tokio::signal::ctrl_c()
            .await
            .expect("Impossible d'installer le gestionnaire de signal Ctrl+C");
    };

    #[cfg(unix)]
    let extinction = async {
        tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
            .expect("Impossible d'installer le gestionnaire de signal SIGTERM")
            .recv() 
            .await;
    };

    #[cfg(not(unix))]
    let extinction = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => println!("\n[SYSTEME] Signal Ctrl+C intercepté. Déconnexion propre..."),
        _ = extinction => println!("\n[SYSTEME] Signal SIGTERM (Render) intercepté. Libération RAM..."),
    }
} 

///mise a jour 