use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct InscriptionRequest {
    pub username: String,
    pub email: String,
    pub password: String,
}

#[derive(Deserialize)]
pub struct ConnexionRequest {
    pub email: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct AuthResponse {
    pub success: bool,
    pub message: String,
    pub token: Option<String>,
    pub user_id: Option<String>,
}

impl AuthResponse {
    pub fn succes(msg: &str, token: Option<String>, user_id: Option<String>) -> Self {
        Self { success: true, message: msg.to_string(), token, user_id }
    }
    pub fn erreur(msg: &str) -> Self {
        Self { success: false, message: msg.to_string(), token: None, user_id: None }
    }
}