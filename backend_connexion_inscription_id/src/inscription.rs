use axum::{extract::State, Json, http::StatusCode};
use crate::models::{InscriptionRequest, AuthResponse};
use crate::securite::{hacher_mot_de_passe, valider_champs_inscription, valider_force_mot_de_passe, assainir_entree};
use crate::id::generer_id_unique; // 🔑 Importation de ton module d'identification nettoyé
use sqlx::PgPool; // 🐘 Import de SQLx pour manipuler PostgreSQL Neon

pub async fn executer_inscription(
    State(pool_database): State<PgPool>, // On récupère l'accès sécurisé à Neon partagé par le main.rs
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

    // 4. Génération de l'identifiant immuable via ton module dédié
    let id_unique = generer_id_unique();

    // 5. Chiffrement lourd Argon2id
    let mot_de_passe_securise = match hacher_mot_de_passe(&payload.password) {
        Ok(h) => h,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, Json(AuthResponse::erreur(&e))),
    };

    // 🐘 6. CONNEXION ET INJECTION RÉELLE IMMUNISÉE
    let requete_insertion = sqlx::query(
        "INSERT INTO users (id, username, email, password) VALUES ($1, $2, $3, $4)"
    )
    .bind(id_unique)
    .bind(nom_propre)
    .bind(email_propre)
    .bind(mot_de_passe_securise)
    .execute(&pool_database)
    .await;

    // Gestion du résultat de l'écriture cloud
    match requete_insertion {
        Ok(_) => {
            println!("🛡️  Utilisateur immunisé créé avec succès sur Neon -> ID: {}", id_unique);
            (StatusCode::CREATED, Json(AuthResponse::succes(
                "Votre compte mondial Yrion a été sécurisé et créé.",
                Some("token-jwt-haute-securite-generable".to_string()),
                Some(id_unique.to_string())
            )))
        },
        Err(e) => {
            println!("❌ Erreur d'écriture Neon : {:?}", e);
            let e_string = e.to_string();
            // Détection si le pseudo ou l'email existe déjà
            let msg_erreur = if e_string.contains("users_username_key") || e_string.contains("users_email_key") || e_string.contains("duplicate key") {
                "Ce nom d'utilisateur ou cet email est déjà enregistré."
            } else {
                "Erreur technique lors de la sauvegarde cloud."
            };
            (StatusCode::CONFLICT, Json(AuthResponse::erreur(msg_erreur)))
        }
    }
}