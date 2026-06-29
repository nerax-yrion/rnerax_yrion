// src/main.rs
use actix_web::{web, App, HttpServer};
use sqlx::postgres::PgPoolOptions; // Utilise MySqlPoolOptions si tu es sur MySQL
use std::io;

mod securite;
mod routes;

#[tokio::main]
async fn main() -> io::Result<()> {
    println!("[SERVEUR YRION] Connexion à la base de données SQL...");

    // 🔴 METS ICI LE LIEN DE TA VRAIE BASE DE DONNÉES SQL (Render, Supabase, Neon...)
    let url_database = "postgres://username:password@localhost:5432/yrion_db";

    let pool_db = PgPoolOptions::new()
        .max_connections(5)
        .connect(url_database)
        .await
        .expect("Impossible de se connecter à la base de données SQL Yrion");

    println!("[SERVEUR YRION] Base SQL connectée. Lancement du serveur sur le port 8080...");

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(pool_db.clone())) // On partage la connexion SQL avec les routes
            .service(routes::connexion)
            .service(routes::verifier_token)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}