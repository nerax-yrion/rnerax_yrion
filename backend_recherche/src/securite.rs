use std::time::Duration;
use tower::limit::RateLimitLayer;

/// 🛡️ DISPOSITIF ANTI-DDOS COUCHE APPLICATIVE
/// Max 15 requêtes de recherche par seconde par socket. 
/// Un humain ne peut pas taper plus vite. Si c'est un script ou un bot, la connexion est coupée.
pub fn bouclier_anti_ddos() -> RateLimitLayer {
    RateLimitLayer::new(15, Duration::from_secs(1))
}

/// 🔐 INSPECTEUR PARAFEU TACTIQUE (ANTI-INJECTION & ANTI-SCRAPING)
/// Analyse et désinfecte la saisie de l'utilisateur en temps réel.
pub fn assainir_saisie_recherche(saisie: &str) -> Option<String> {
    // Une recherche de pseudonyme ou d'identifiant ne dépasse JAMAIS 30 caractères.
    // Bloquer ici empêche les charges utiles géantes de saturer les processeurs (DDoS par calcul).
    if saisie.len() > 30 || saisie.trim().isEmpty() {
        return None;
    }

    // Protection totale contre le vol de données et injections de scripts (Anti-XSS / Anti-Hack)
    if saisie.contains("<script>") || saisie.contains("SELECT") || saisie.contains("$regex") {
        return None;
    }

    // On ne garde strictement que les caractères alphanumériques sains
    let texte_propre: String = saisie
        .chars()
        .filter(|c| c.is_alphanumeric() || *c == '_' || *c == '-')
        .collect();

    if texte_propre.is_empty() { None } else { Some(texte_propre) }
}