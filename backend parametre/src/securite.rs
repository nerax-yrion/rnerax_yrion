use jsonwebtoken::{decode, DecodingKey, Validation};
use serde::{Deserialize, Serialize};
use crate::erreurs::ErreurApplication;

#[derive(Debug, Serialize, Deserialize)]
pub struct DonneesSession {
    pub sub: String, 
    pub exp: usize,  
}

/// SYSTEM DE NETTOYAGE : Élimine les risques d'injection
pub fn inspecter_nettoyage_attaque(entree: &str) -> Result<String, ErreurApplication> {
    let chaine_nettoyee = entree.trim();

    if chaine_nettoyee.len() > 50 {
        tracing::error!("🚨 SÉCURITÉ : Entrée trop longue.");
        return Err(ErreurApplication::AttaqueDetectee);
    }

    // Protection anti-XSS via remplacements standardisés (sans slash d'échappement problématique)
    let chaine_securisee = chaine_nettoyee
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&#x27;")
        .replace('/', "&#x2F;");

    // Détection des structures d'injection SQL fondamentales
    if chaine_securisee.contains("--") || chaine_securisee.contains("/*") || chaine_securisee.contains(';') {
        tracing::error!("🚨 SÉCURITÉ : Tentative d'injection détectée.");
        return Err(ErreurApplication::AttaqueDetectee);
    }

    Ok(chaine_securisee)
}

/// VALIDATION CRYPTOGRAPHIQUE : Vérification du jeton de session JWT
pub fn valider_jeton_securise(token: &str, cle_secrete: &str) -> Result<DonneesSession, ErreurApplication> {
    let cle = DecodingKey::from_secret(cle_secrete.as_bytes());
    let validation = Validation::default();
    
    decode::<DonneesSession>(token, &cle, &validation)
        .map(|donnees| donnees.claims)
        .map_err(|_| ErreurApplication::SessionInvalide)
}
//1