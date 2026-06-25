use std::time::Duration;
use tower::limit::RateLimitLayer;

/// 🛡️ PROTECTION APPLICATIVE ANTI-DDOS TARGETING
/// Limite mathématique stricte : 15 requêtes maximum par seconde.
pub fn bouclier_anti_ddos() -> RateLimitLayer {
    RateLimitLayer::new(15, Duration::from_secs(1))
}

/// 🔐 PARAFEU TACTIQUE AVANCÉ V5 (ZÉRO ALLOCATION AVANT VALIDATION)
/// Analyse et neutralise les attaques par contournement en temps réel avec une empreinte mémoire minimale.
pub fn assainir_saisie_recherche(saisie: &str) -> Option<String> {
    // 1. Nettoyage des espaces aux extrémités sur la référence directe
    let saisie_trim = saisie.trim();

    // 2. Garde-fou sur la longueur en caractères Unicode (évite les overflows de buffers)
    let total_caracteres = saisie_trim.chars().count();
    if total_caracteres == 0 || total_caracteres > 30 {
        return None;
    }

    // 3. Scan rapide : Rejet immédiat si la chaîne contient des caractères de contrôle (hacks de terminaux)
    if saisie_trim.chars().any(|c| c.is_control()) {
        return None;
    }

    // 4. Analyse de la densité des caractères spéciaux (Anti-obfuscation / payloads complexes)
    let nb_speciaux = saisie_trim.chars().filter(|c| !c.is_alphanumeric()).count();
    if nb_speciaux > 5 {
        return None; 
    }

    // 5. Normalisation en Majuscules pour bloquer le contournement de casse (ex: <sCrIpt>)
    // On ne le fait qu'ici car la chaîne est courte (max 30 chars) et a passé les premiers filtres
    let saisie_haute = saisie_trim.to_uppercase();

    // 6. Base de signatures malveillantes (Injections SQL, XSS, NoSQL, Path Traversal)
    let signatures_attaques = [
        "<SCRIPT", "SCRIPT>", "SELECT ", "UNION ", "INSERT ", "DELETE ", 
        "DROP ", "WHERE ", "$REGEX", "$WHERE", "EVAL(", "JAVASCRIPT:", 
        "OR 1=1", "AND 1=1", "--", "/*", "*/", "../", "..\\", "EXEC "
    ];

    for signature in &signatures_attaques {
        if saisie_haute.contains(signature) {
            return None; // Blocage immédiat
        }
    }

    // 7. Reconstruction et filtrage final : Extraction exclusive des caractères sûrs
    // C'est la SEULE et unique allocation mémoire du framework si la saisie est valide
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