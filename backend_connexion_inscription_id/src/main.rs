use axum::{routing::post, Router};
use std::net::SocketAddr;
use tower::ServiceBuilder;
use tower_governor::{governor::GovernorConfigBuilder, GovernorLayer};

mod models;
mod id;
mod securite;
mod inscription;
mod connexion;

#[tokio::main]
async fn main() {
    // PROTECTION ANTI-DDOS & FORCE BRUTE : Maximum 5 requêtes par seconde par adresse IP
    let config_anti_ddos = Box::new(
        GovernorConfigBuilder::default()
            .per_second(1)
            .burst_size(5)
            .finish()
            .unwrap(),
    );

    // Construction des routes d'Yrion protégées par notre pare-feu applicatif
    let app = Router::new()
        .route("/api/auth/register", post(inscription::executer_inscription))
        .route("/api/auth/login", post(connexion::executer_connexion))
        .layer(
            ServiceBuilder::new()
                .layer(GovernorLayer {
                    config: Box::leak(config_anti_ddos),
                })
        );

    let adresse_serveur = SocketAddr::from(([0, 0, 0, 0], 4000));
    println!("🛡️  FORTERESSE CYBER-SÉCURISÉE YRION LANCÉE SUR LE PORT : {}", adresse_serveur);

    let listener = tokio::net::TcpListener::bind(&adresse_serveur).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}