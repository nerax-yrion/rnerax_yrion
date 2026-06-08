use axum::{Json, http::StatusCode};
use crate::models::{InscriptionRequest, AuthResponse};
use crate::securite::{hacher_mot_de_passe, valider_champs_inscription, valider_force_mot_de_passe, assainir_entree};
use crate::id::generer_id_unique;

pub async fn executer_inscription(
    Json(payload): Json<InscriptionRequest>,
) -> (StatusCode, Json<AuthResponse>) {
    // 1. Assainissement immédiat des entrées contre le XSS / Injections
    let nom_propre = assainir_entree(&payload.username);
    let email_propre = assainir_entree(&payload.email);

    if nom_propre.is_empty() || email_propre.is_empty() || payload.password.is_empty() {
        return (StatusCode::BAD_REQUEST, Json(AuthResponse::erreur("Données invalides ou corrompues.")));
    }

    // 2. Vérification des règles strictes du mot de passe (8+ car, 1 Maj, 1 Chiffre)
    if let Err(msg) = valider_force_mot_de_passe(&payload.password) {
        return (StatusCode::BAD_REQUEST, Json(AuthResponse::erreur(&msg)));
    }

    // 3. Validation de la structure regex
    if let Err(msg) = valider_champs_inscription(&nom_propre, &email_propre) {
        return (StatusCode::BAD_REQUEST, Json(AuthResponse::erreur(&msg)));
    }

    // 4. Génération de l'identifiant immuable Yrion
    let id_unique = generer_id_unique();

    // 5. Chiffrement lourd Argon2id
    let mot_de_passe_securise = match hacher_mot_de_passe(&payload.password) {
        Ok(h) => h,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, Json(AuthResponse::erreur(&e))),
    };

    // [Connexion Pool Base de données non bloquante ici via SQLx]
    println!("Utilisateur immunisé créé en DB -> ID: {}", id_unique);

    (StatusCode::CREATED, Json(AuthResponse::succes(
        "Votre compte mondial Yrion a été sécurisé et créé.",
        Some("token-jwt-haute-securite-generable".to_string()),
        Some(id_unique)
    )))
}