use std::net::SocketAddr;
use std::sync::Arc;
use axum::{routing::get, Router};
use tokio::sync::RwLock;
use tower_http::cors::CorsLayer;

mod protocole;
mod registre;
mod gestionnaire;
mod securite;

use registre::StationCentrale;
use gestionnaire::point_entree_liaison;
use securite::bouclier_anti_ddos;

#[tokio::main]
async fn main() {
    // Allocation de sécurité massive à l'allumage pour 1 000 000 d'utilisateurs simultanés
    let noyau_central = Arc::new(RwLock::new(StationCentrale::initialiser(1000000)));

    let application = Router::new()
        .route("/yrion_univers", get(point_entree_liaison))
        .layer(CorsLayer::permissive())
        .layer(bouclier_anti_ddos()) // Bouclier matériel de protection active
        .with_state(noyau_central)

    // ⚡ CONFIGURATION DU PORT REQUIS : PORT 2009
    let adresse_reseau = SocketAddr::from(([0, 0, 0, 0], 2009));
    let ecouteur_reseau = tokio::net::TcpListener::bind(adresse_reseau).await.unwrap();
    
    println!("========================================================");
    println!("👑 ARCHITECTURE FINALE YRION QUANTIQUE PLACÉE SUR LE PORT 2009");
    println!("⚡ PROTECTION ABSOLUE ET CHANNELS INDÉPENDANTS ACTIVÉS");
    println!("========================================================");

    axum::serve(ecouteur_reseau, application).await.unwrap();
}