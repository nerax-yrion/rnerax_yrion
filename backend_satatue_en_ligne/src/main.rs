use std::net::SocketAddr;
use std::sync::Arc;
use axum::{routing::get, Router};
use tokio::sync::RwLock;
use tower_http::cors::CorsLayer;

// Chargement de tous nos fichiers en français
mod protocole;
mod registre;
mod gestionnaire;
mod securite;

use registre::PlanetePresence;
use gestionnaire::tunnel_websocket_presence;
use securite::bouclier_anti_ddos;

#[tokio::main]
async fn main() {
    // Allocation mémoire massive pour être paré à toute ouverture globale
    let registre_spatial = Arc::new(RwLock::new(PlanetePresence::initialiser(100000)));

    // Configuration des routes avec injection de la couche de sécurité anti-DDoS
    let application = Router::new()
        .route("/liaison_statut", get(tunnel_websocket_presence))
        .layer(CorsLayer::permissive())
        .layer(bouclier_anti_ddos()) // 🛡️ Le bouclier entoure toute l'application ici !
        .with_state(registre_spatial);

    // Démarrage forcé sur le PORT 2000
    let adresse_serveur = SocketAddr::from(([0, 0, 0, 0], 2000));
    let ecouteur_reseau = tokio::net::TcpListener::bind(adresse_serveur).await.unwrap();
    
    println!("========================================================");
    println!("🛸 SERVEUR YRION SÉCURISÉ NIVEAU MILITAIRE HAUTE DISPO");
    println!("📡 Port : {} | Protection Anti-DDoS activée", adresse_serveur.port());
    println!("========================================================");

    axum::serve(ecouteur_reseau, application).await.unwrap();
}