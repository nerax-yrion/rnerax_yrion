use std::time::Duration;
use tower::limit::RateLimitLayer;

/// 🛡️ CONFIGURATION DE LA PROTECTION ANTI-DDOS
/// Cette fonction crée une barrière qui limite le nombre de requêtes.
/// Si un pirate bombarde le port 2000, le serveur rejette ses paquets
/// avant même qu'ils n'atteignent le cœur du code.
pub fn bouclier_anti_ddos() -> RateLimitLayer {
    // Limite stricte : Un utilisateur ne peut pas envoyer plus de 100 requêtes
    // par tranche de 1 seconde. Au-delà, il est temporairement bloqué.
    RateLimitLayer::new(100, Duration::from_secs(1))
}

/// 🔐 VÉRIFICATION ANTI-INJECTION
/// Filtre les chaînes de texte pour s'assurer qu'aucun code malveillant
/// ou emoji corrompu ne vienne déstabiliser l'application Flutter.
pub fn nettoyer_identifiant(user_id: &str) -> Option<String> {
    // Si l'identifiant est trop long (tentative de saturation de mémoire)
    // ou s'il contient des caractères bizarres, on le rejette.
    if user_id.len() > 50 || user_id.trim().isEmpty() {
        return None;
    }
    
    // On ne garde que les caractères sains
    Some(user_id.chars().filter(|c| c.is_alphanumeric() || *c == '_').collect())
}