use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ErreurApplication {
    #[error("🚨 Violation de sécurité : Payload malveillant bloqué par le pare-feu !")]
    AttaqueDetectee,
    #[error("🔒 Authentification requise : Signature de session invalide ou expirée.")]
    SessionInvalide,
}

impl IntoResponse for ErreurApplication {
    fn into_response(self) -> Response {
        let (statut, message_erreur) = match self {
            ErreurApplication::AttaqueDetectee => (StatusCode::FORBIDDEN, self.to_string()),
            ErreurApplication::SessionInvalide => (StatusCode::UNAUTHORIZED, self.to_string()),
        };

        // Structuration opaque pour empêcher les hackers d'analyser le comportement interne du serveur
        let corps = Json(json!({
            "statut": "CRYPTO_ARMOR_BLOCKED",
            "erreur": message_erreur,
        }));

        (statut, corps).into_response()
    }
}

//1
