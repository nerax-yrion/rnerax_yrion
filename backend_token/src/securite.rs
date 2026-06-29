// src/securite.rs
use argon2::{
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use rand_core::{OsRng, RngCore};
use sha2::Sha256;
use hmac::{Hmac, Mac};
use uuid::Uuid;

type HmacSha256 = Hmac<Sha256>;

pub struct YrionSecurite;

impl YrionSecurite {
    pub fn hacher_mot_de_passe(mot_de_passe: &str) -> Result<String, &'static str> {
        let salt = SaltString::generate(&mut OsRng);
        let argon2 = Argon2::default();
        match argon2.hash_password(mot_de_passe.as_bytes(), &salt) {
            Ok(hash) => Ok(hash.to_string()),
            Err(_) => Err("Erreur de chiffrement."),
        }
    }

    pub fn verifier_mot_de_passe(mot_de_passe: &str, hash_stocke: &str) -> bool {
        let argon2 = Argon2::default();
        match PasswordHash::new(hash_stocke) {
            Ok(parsed_hash) => argon2.verify_password(mot_de_passe.as_bytes(), &parsed_hash).is_ok(),
            Err(_) => false,
        }
    }

    pub fn generer_token_session() -> String {
        let mut octets = [0u8; 16];
        OsRng.fill_bytes(&mut octets);
        Uuid::new_v4().to_string()
    }

    pub fn hacher_token_pour_db(token: &str, cle_secrete: &[u8]) -> String {
        let mut mac = HmacSha256::new_from_slice(cle_secrete).expect("Clé invalide");
        mac.update(token.as_bytes());
        hex::encode(mac.finalize().into_bytes())
    }
}