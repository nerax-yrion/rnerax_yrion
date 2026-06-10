use axum::Router;
use axum::routing::{get, post};
use std::sync::Arc;

mod controleurs;
mod erreurs;
mod modeles;
mod securite;
mod serveur; // Enregistre le nouveau fichier serveur

#[derive(Clone)]
pub struct EtatApplication {
    pub cle_signature: String,
}

#[tokio::main]
async fn main() {
    // Initialisation des rapports système dans la console
    tracing_subscriber::fmt()
        .with_env_filter("info")
        .init();

    tracing::info!("🚀 Activation du bouclier de sécurité Yrion Core Backend...");

    // Initialisation de l'état persistant avec la clé maîtresse de sécurité
    let etat = Arc::new(EtatApplication {
        cle_signature: "CLE_SECRET_MAXIMA_SECURITY_YRION_2026_GLOBAL_STARTUP".to_string(),
    });

    // Configuration propre des routes de l'API
    let routes_api = Router::new()
        .route("/authentification/changer-compte", post(controleurs::changer_compte))
        .route("/authentification/deconnexion", post(controleurs::interrompre_session))
        .route("/utilisateur/donnees-flux", get(controleurs::recuperer_flux_utilisateur))
        .with_state(etat);

    // 🚀 Lancement intelligent via le second fichier
    serveur::demarrer(routes_api).await;
}

//1