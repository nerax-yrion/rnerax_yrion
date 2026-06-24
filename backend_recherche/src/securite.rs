use std::time::Duration;
use tower::limit::RateLimitLayer;

/// 🛡️ DISPOSITIF ANTI-DDOS COUCHE APPLICATIVE (VERSION SÉCURITÉ MAXIMALE)
/// Limite stricte : 15 requêtes max par seconde.
pub fn bouclier_anti_ddos() -> RateLimitLayer {
    RateLimitLayer::new(15, Duration::from_secs(1))
}

/// 🔐 INJECTEUR PARAFEU TACTIQUE AVANCÉ (ANTI-INJECTION, MULTI-ENCAPSULATION & ANTI-BYPASS)
/// Analyse, nettoie et neutralise les attaques par contournement en temps réel.
pub fn assainir_saisie_recherche(saisie: &str) -> Option<String> {
    // 1. Éliminer les attaques par caractères de contrôle ou espaces invisibles Unicode
    let saisie_nettoyee: String = saisie
        .chars()
        .filter(|c| !c.is_control()) // Bloque les caractères invisibles de hack de terminal
        .collect();

    let saisie_trim = saisie_nettoyee.trim();
    
    // 2. Vérification stricte de la longueur en caractères (et non en octets)
    if saisie_trim.chars().count() > 30 || saisie_trim.is_empty() {
        return None;
    }

    // 3. Normalisation en majuscules pour bloquer les variantes de contournement (ex: <ScRiPt>, sElEcT)
    let saisie_haute = saisie_trim.to_uppercase();

    // 4. Liste noire étendue de niveau militaire (Injections, XSS, NoSQL, Path Traversal)
    let signatures_attaques = [
        "<SCRIPT", "SCRIPT>", "SELECT ", "UNION ", "INSERT ", "DELETE ", 
        "DROP ", "WHERE ", "$REGEX", "$WHERE", "EVAL(", "JAVASCRIPT:", 
        "OR 1=1", "AND 1=1", "--", "/*", "*/", "../", "..\\", "EXEC "
    ];

    for signature in &signatures_attaques {
        if saisie_haute.contains(signature) {
            return None; // Blocage immédiat si une signature suspecte est détectée
        }
    }

    // 5. Détection d'obfuscation : Si la chaîne contient trop de caractères spéciaux répétés
    // Bloque les attaques par force brute ou injection de payloads cryptés
    let nb_speciaux = saisie_trim.chars().filter(|c| !c.is_alphanumeric()).count();
    if nb_speciaux > 5 {
        return None; // Une simple recherche de pseudo n'a pas besoin de plus de 5 symboles (_, -, etc.)
    }

    // 6. Filtrage final ultra-rapide : Seuls l'alphanumérique, le tiret bas et le tiret du milieu sont tolérés
    let texte_propre: String = saisie_trim
        .chars()
        .filter(|c| c.is_alphanumeric() || *c == '_' || *c == '-')
        .collect();

    if texte_propre.is_empty() { 
        None 
    } else { 
        Some(texte_propre) 
    }
}

// mise a jour numero 1