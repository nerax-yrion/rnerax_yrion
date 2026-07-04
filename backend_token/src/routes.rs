// src/routes.rs
use actix_web::{post, web, HttpResponse, Responder};
use serde::{Deserialize, Serialize};
use sqlx::PgPool; // Remplace par MySqlPool si tu utilises MySQL
use chrono::Utc;
use crate::securite::YrionSecurite;

const CLE_SECRET_SERVEUR: &[u8] = b"yrion_quantum_key_secret_777_production";

#[derive(Deserialize)]
pub struct RequeteConnexion {
    pub email: String,
    pub mot_de_passe: String,
}

#[derive(Deserialize)]
pub struct RequeteVerificationToken {
    pub token: String,
}

#[derive(Serialize)]
pub struct ReponseAuth {
    pub succes: bool,
    pub message: String,
    pub token: Option<String>,
}

/// 📥 CONNEXION CLASSIQUE (Email + Mot de passe)
#[post("/api/auth/connexion")]
pub async fn connexion(db: web::Data<PgPool>, corps: web::Json<RequeteConnexion>) -> impl Responder {
    // 1. On cherche l'utilisateur dans ta base SQL grâce à son email
    let utilisateur = sqlx::query!(
        "SELECT id, mot_de_passe_hash FROM utilisateurs WHERE email = $1",
        corps.email
    )
    .fetch_optional(db.get_ref())
    .await;

    match utilisateur {
        Ok(Some(row)) => {
            // 2. On vérifie le mot de passe reçu avec le hash de ta DB SQL
            if YrionSecurite::verifier_mot_de_passe(&corps.mot_de_passe, &row.mot_de_passe_hash) {
                // 3. MDP Correct -> On génère le fameux Token secret
                let token_client = YrionSecurite::generer_token_session();
                let token_db_hash = YrionSecurite::hacher_token_pour_db(&token_client, CLE_SECRET_SERVEUR);
                let date_actuelle = Utc::now().to_rfc3339();

                // 4. On enregistre ce Token haché dans ta table SQL 'sessions'
                let _ = sqlx::query!(
                    "INSERT INTO sessions (token_hash, utilisateur_id, date_creation) VALUES ($1, $2, $3)",
                    token_db_hash,
                    row.id,
                    date_actuelle
                )
                .execute(db.get_ref())
                .await;

                // 5. On renvoie le Token propre à Flutter
                HttpResponse::Ok().json(ReponseAuth {
                    succes: true,
                    message: "Connexion réussie !".to_string(),
                    token: Some(token_client),
                })
            } else {
                HttpResponse::Unauthorized().json(ReponseAuth {
                    succes: false, message: "Mot de passe incorrect.".to_string(), token: None,
                })
            }
        }
        Ok(None) => HttpResponse::NotFound().json(ReponseAuth {
            succes: false, message: "Aucun utilisateur avec cet e-mail.".to_string(), token: None,
        }),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

/// 📥 VERIFICATION DU TOKEN (Appelée en tâche de fond par ton Splash Screen)
#[post("/api/auth/verifier_token")]
pub async fn verifier_token(db: web::Data<PgPool>, corps: web::Json<RequeteVerificationToken>) -> impl Responder {
    // 1. On applique le hachage de sécurité sur le Token envoyé par le Splash Screen
    let token_db_recherche = YrionSecurite::hacher_token_pour_db(&corps.token, CLE_SECRET_SERVEUR);

    // 2. On regarde s'il existe une session active correspondante dans ton SQL
    let session = sqlx::query!(
        "SELECT utilisateur_id FROM sessions WHERE token_hash = $1",
        token_db_recherche
    )
    .fetch_optional(db.get_ref())
    .await;

    match session {
        Ok(Some(_)) => {
            // Le token existe ! L'utilisateur est connecté automatiquement sans mot de passe
            HttpResponse::Ok().json(ReponseAuth {
                succes: true,
                message: "Session restaurée !".to_string(),
                token: Some(corps.token.clone()),
            })
        }
        _ => HttpResponse::Unauthorized().json(ReponseAuth {
            succes: false,
            message: "Session expirée. Reconnexion obligatoire.".to_string(),
            token: None,
        }),
    }
}