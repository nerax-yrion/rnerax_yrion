use std::net::SocketAddr;
use std::sync::Arc;
use axum::{routing::get, Router, response::Html};
use tokio::sync::RwLock;
use tower_http::{cors::CorsLayer, compression::CompressionLayer};
use tower::ServiceBuilder;

mod protocole;
mod registre;
mod gestionnaire;
mod securite;
mod moteur_recherche;

use registre::CatalogueUtilisateurs;
use gestionnaire::point_entree_recherche;
use securite::bouclier_anti_ddos;

/// 🌐 INTERFACE D'ACCUEIL NAVIGATEUR (TEXTE ESSENTIEL)
/// Affiche uniquement le créateur, la version et le statut en ligne.
async fn page_accueil() -> Html<&'static str> {
    Html(r#"
        Créateur: Nerax_Yrion
        Version: 4.0.0
        Status: En ligne
    "#)
}

#[tokio::main]
async fn main() {
    // 🛡️ ALLOCATION MÉMOIRE PRÉ-CALCULÉE INDUSTRIELLE
    let base_donnees_recherche = Arc::new(RwLock::new(CatalogueUtilisateurs::initialiser_haute_capacite(1000000)));

    // 🚀 CONFIGURATION DES PROTOCOLES ET DES COUCHES SÉCURISÉES EN SÉRIE
    let application = Router::new()
        .route("/", get(page_accueil)) 
        .route("/yrion_recherche", get(point_entree_recherche)) 
        .layer(CorsLayer::permissive())
        .layer(
            ServiceBuilder::new()
                .layer(CompressionLayer::new())
                .layer(bouclier_anti_ddos())
        )
        .with_state(base_donnees_recherche);

    // ⚡ LECTURE INTERNATIONALE DU PORT DE DÉPLOIEMENT
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

    // 🛑 DÉCLENCHEMENT DU SERVEUR AVEC BOUCLIER D'ARRÊT PROPRE (GRACEFUL SHUTDOWN)
    axum::serve(ecouteur_reseau, application)
        .with_graceful_shutdown(attendre_signal_extinction())
        .await
        .unwrap();
}

/// 🛑 INTERCEPTEUR DE SIGNAL DE FIN DE VIE DU SERVEUR
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
        _ = ctrl_c => println!("\n[SYSTEME] Signal Ctrl+C intercepté. Extinction propre en cours..."),
        _ = extinction => println!("\n[SYSTEME] Signal SIGTERM (Render) intercepté. Nettoyage et fermeture..."),
    }
} 

// mise ajour du main.rs niveau 1 