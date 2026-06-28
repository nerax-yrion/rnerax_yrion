use std::net::SocketAddr;
use std::sync::Arc;
use std::collections::HashMap;
use axum::{routing::get, Router, middleware::from_fn};
use tokio::sync::RwLock;
use tower_http::cors::CorsLayer;

mod protocole;
mod registre;
mod gestionnaire;
mod securite;
mod message_normal;
mod modifier_message;
mod message_vocal;
mod appel_normal;
mod appel_video;
pub mod notifications; // 🛰️ ACTIVATION DU SOUS-DOSSIER QUANTIQUE ELITE

use registre::StationCentrale;
use gestionnaire::point_entree_liaison;
use securite::bouclier_anti_ddos;

// Structure globale mise à jour pour inclure l'état des notifications en RAM
pub struct AppStateYrion {
    pub noyau_central: Arc<RwLock<StationCentrale>>,
    pub notifs_actifs: notifications::TransmissionNotifMap, // Moteur d'envoi résilient
}

#[tokio::main]
async fn main() {
    // 1. Allocation de sécurité massive à l'allumage pour 1 000 000 d'utilisateurs simultanés
    let noyau_central = Arc::new(RwLock::new(StationCentrale::initialiser(1000000)));

    // 2. Initialisation du buffer de secours et de la file prioritaire en RAM pour les notifications
    let notifs_actifs = Arc::new(RwLock::new(HashMap::new()));

    // 3. Fusion des états dans un conteneur global d'élite
    let etat_global = Arc::new(AppStateYrion {
        noyau_central,
        notifs_actifs,
    });

    // Création de l'application avec enregistrement propre du middleware et injection de l'état
    let application = Router::new()
        .route("/yrion_univers", get(point_entree_liaison))
        .layer(CorsLayer::permissive())
        .layer(from_fn(bouclier_anti_ddos)) // 💡 APPLIQUÉ VIA AXUM NATIVE : Sécurité maximale contre les attaques
        .with_state(etat_global); // Injection de l'état étendu

    // ⚡ CONFIGURATION DU PORT REQUIS : PORT 2009
    let adresse_reseau = SocketAddr::from(([0, 0, 0, 0], 2009));
    let ecouteur_reseau = tokio::net::TcpListener::bind(adresse_reseau).await.unwrap();
    
    println!("========================================================");
    println!("👑 ARCHITECTURE FINALE YRION QUANTIQUE PLACÉE ON PORT 2009");
    println!("⚡ PROTECTION ABSOLUE ET CHANNELS INDÉPENDANTS ACTIVÉS");
    println!("🚀 MOTEUR DE NOTIFICATIONS AVANCÉ INTÉGRÉ AVEC SUCCÈS");
    println!("========================================================");

    axum::serve(ecouteur_reseau, application).await.unwrap();
}

// mise a jour niveau 2