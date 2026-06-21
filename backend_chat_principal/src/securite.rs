use std::time::Duration;
use tower::limit::RateLimitLayer;
use std::collections::HashMap;
use std::sync::Mutex;

pub struct RadarSecurite {
    // Compteur de requêtes par adresse IP pour bloquer le vol de données et le DDoS
    pub historique_frappes: HashMap<String, u32>,
}

/// 🛡️ BOUCLIER DDOS RESEAU (Niveau Couche App)
pub fn bouclier_anti_ddos() -> RateLimitLayer {
    // 30 requêtes max par seconde. Au-delà, blocage matériel de la socket.
    RateLimitLayer::new(30, Duration::from_secs(1))
}

/// 🔐 INSPECTEUR SÉCURITÉ DE ZONE
pub fn assainir_identifiant(id: &str) -> Option<String> {
    if id.len() > 40 || id.trim().isEmpty() { return None; }
    let filtre: String = id.chars().filter(|c| c.is_alphanumeric() || *c == '_').collect();
    if filtre.is_empty() { None } else { Some(filtre) }
}

pub fn valider_texte(contenu: &str) -> Option<String> {
    const LIMITE_OCTETS: usize = 4000;
    if contenu.len() > LIMITE_OCTETS || contenu.contains("<script>") {
        return None; // Bloque les injections de code XSS visant à voler des données
    }
    Some(contents.to_string())
}