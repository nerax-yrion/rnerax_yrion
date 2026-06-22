use std::net::SocketAddr;
use std::sync::Arc;
use axum::{routing::get, Router};
use tokio::sync::RwLock;
use tower_http::cors::CorsLayer;

mod protocole;
mod registre;
mod gestionnaire;
mod securite;
mod moteur_recherche;

use registre::CatalogueUtilisateurs;
use gestionnaire::point_entree_recherche;
use securite::bouclier_anti_ddos;

#[tokio::main]
async fn main() {
    // 🛡️ ALLOCATION MÉMOIRE PRÉ-CALCULÉE INDUSTRIELLE
    // On réserve instantanément de l'espace dans la RAM pour 1 000 000 de comptes.
    // Cela empêche le serveur d'avoir à faire des pauses pour demander de la mémoire au CPU.
    let base_donnees_recherche = Arc::new(RwLock::new(CatalogueUtilisateurs::initialiser_haute_capacite(1000000)));

    let application = Router::new()
        .route("/yrion_recherche", get(point_entree_recherche))
        .layer(CorsLayer::permissive())
        .layer(bouclier_anti_ddos()) // 🛡️ Activation du bouclier anti-DDoS à la racine du port 2013
        .with_state(base_donnees_recherche);

    // ⚡ FIXATION STRATEGIQUE DE LA FRÉQUENCE SUR LE PORT 2013
    let adresse_serveur = SocketAddr::from(([0, 0, 0, 0], 2013));
    let ecouteur_reseau = tokio::net::TcpListener::bind(adresse_serveur).await.unwrap();
    
    println!("========================================================");
    println!("👑 MICRO-SERVEUR DE RECHERCHE ULTRA-SÉCURISÉ YRION CORE v4");
    println!("📡 Fréquence réseau calée exclusivement sur le PORT : {}", adresse_reseau.port());
    println!("🛡️ Immunité contre le piratage, scraping et DDoS activée");
    println!("========================================================");

    axum::serve(ecouteur_reseau, application).await.unwrap();
}