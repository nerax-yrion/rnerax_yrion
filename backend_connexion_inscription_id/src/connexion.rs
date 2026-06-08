use axum::{Json, http::StatusCode};
use crate::models::{ConnexionRequest, AuthResponse};
use crate::securite::{verifier_mot_de_passe, assainir_entree};

pub async fn executer_connexion(
    Json(payload): Json<ConnexionRequest>,
) -> (StatusCode, Json<AuthResponse>) {
    let email_propre = assainir_entree(&payload.email);

    if email_propre.is_empty() || payload.password.is_empty() {
        return (StatusCode::BAD_REQUEST, Json(AuthResponse::erreur("Veuillez remplir tous les critères.")));
    }

    // Simulation de récupération sécurisée depuis yrion.sql
    let compte_trouve = true;
    let hachage_db = "$argon2id$v=19$m=19456,t=2,p=1$Y2hhcXVlY29tcHRl$..."; 
    let id_db = "id-uuid-elite-global";

    if !compte_trouve {
        // Anti-énumération de comptes : On renvoie la même erreur pour masquer l'inexistence de l'email
        return (StatusCode::UNAUTHORIZED, Json(AuthResponse::erreur("Identifiants non valides.")));
    }

    // Comparaison temporelle stricte
    if verifier_mot_de_passe(&payload.password, hachage_db) {
        (StatusCode::OK, Json(AuthResponse::succes(
            "Authentification validée.",
            Some("session-jwt-yrion-secure".to_string()),
            Some(id_db.to_string())
        )))
    } else {
        (StatusCode::UNAUTHORIZED, Json(AuthResponse::erreur("Identifiants non valides.")))
    }
}