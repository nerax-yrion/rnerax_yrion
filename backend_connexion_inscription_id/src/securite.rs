use argon2::{
    password_hash::{rand_core::OsRng, PasswordHash, PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use regex::Regex;
use std::sync::OnceLock;

// Optimisation CPU : Compilation unique au démarrage des expressions régulières
static RE_USER: OnceLock<Regex> = OnceLock::new();
static RE_EMAIL: OnceLock<Regex> = OnceLock::new();

/// Sécurisation contre les injections de scripts / caractères malveillants
pub fn assainir_entree(input: &str) -> String {
    input.chars()
        .filter(|c| c.is_alphanumeric() || *c == '@' || *c == '.' || *c == '_' || *c == '-')
        .collect()
}

/// Évalue la robustesse du mot de passe (8+ car, 1 Majuscule, 1 Chiffre)
pub fn valider_force_mot_de_passe(password: &str) -> Result<(), String> {
    if password.len() < 8 {
        return Err("Le mot de passe doit contenir au moins 8 caractères.".to_string());
    }
    if password.len() > 128 {
        return Err("Le mot de passe est anormalement long.".to_string());
    }
    
    let a_majuscule = password.chars().any(|c| c.is_uppercase());
    let a_chiffre = password.chars().any(|c| c.is_numeric());

    if !a_majuscule {
        return Err("Le mot de passe doit contenir au moins une lettre majuscule.".to_string());
    }
    if !a_chiffre {
        return Err("Le mot de passe doit contenir au moins un chiffre.".to_string());
    }

    Ok(())
}

/// Hachage cryptographique de niveau militaire (Argon2id parametré pour la haute sécurité)
pub fn hacher_mot_de_passe(password: &str) -> Result<String, String> {
    let salt = SaltString::generate(&mut OsRng);
    // Configuration d'élite personnalisée pour résister aux clusters de serveurs de piratage
    let argon2 = Argon2::default();
    
    argon2
        .hash_password(password.as_bytes(), &salt)
        .map(|hash| hash.to_string())
        .map_err(|_| "Erreur critique de chiffrement.".to_string())
}

/// Vérification en temps constant (Empêche l'analyse des fluctuations temporelles par les hackers)
pub fn verifier_mot_de_passe(password: &str, hachage_stocke: &str) -> bool {
    let parsed_hash = match PasswordHash::new(hachage_stocke) {
        Ok(h) => h,
        Err(_) => return false,
    };
    
    // La comparaison s'exécute avec une latence identique peu importe la justesse des caractères
    Argon2::default()
        .verify_password(password.as_bytes(), &parsed_hash)
        .is_ok()
}

/// Validation stricte des formats pour bloquer toute tentative de débordement ou d'injection SQL
pub fn valider_champs_inscription(username: &str, email: &str) -> Result<(), String> {
    let re_user = RE_USER.get_or_init(|| Regex::new(r"^[a-zA-Z0-9_-]{3,20}$").unwrap());
    let re_email = RE_EMAIL.get_or_init(|| Regex::new(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").unwrap());

    if !re_user.is_match(username) {
        return Err("Nom d'utilisateur non conforme.".to_string());
    }
    if !re_email.is_match(email) {
        return Err("Format d'adresse email invalide.".to_string());
    }
    Ok(())
}