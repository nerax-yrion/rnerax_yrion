use std::collections::HashMap;
use std::sync::Mutex;
use std::time::{Duration, Instant};

/// 🛡️ Limiteur de débit haute performance pour contrer les attaques DoS
pub struct LimiteurDeDebit {
    // Utilisation d'un Mutex standard pour des opérations mémoires ultra-rapides non bloquantes
    requetes: Mutex<HashMap<String, (u32, Instant)>>,
}

impl LimiteurDeDebit {
    pub fn new() -> Self {
        Self {
            requetes: Mutex::new(HashMap::new()),
        }
    }

    /// Vérifie si une IP respecte les quotas (max 30 requêtes par 10 secondes)
    pub fn verifier_ip(&self, ip: String) -> bool {
        let mut requetes = self.requetes.lock().unwrap();
        let maintenant = Instant::now();
        
        // Nettoyage périodique pour éviter les fuites de mémoire (RAM)
        if requetes.len() > 5000 {
            requetes.retain(|_, (_, instant)| maintenant.duration_since(*instant) < Duration::from_secs(10));
        }

        let (compteur, fenetre) = requetes.entry(ip).or_insert((0, maintenant));
        
        if maintenant.duration_since(*fenetre) > Duration::from_secs(10) {
            *compteur = 1;
            *fenetre = maintenant;
            true
        } else {
            *compteur += 1;
            *compteur <= 30
        }
    }
}

/// 📝 Assainissement de texte ultra-rapide sans allocations superflues
pub fn assainir_texte(entree: &str) -> String {
    let mut resultat = String::with_capacity(entree.len());
    for caractere in entree.chars() {
        match caractere {
            '<' => resultat.push_str("&lt;"),
            '>' => resultat.push_str("&gt;"),
            '"' => resultat.push_str("&quot;"),
            '\'' => resultat.push_str("&#x27;"),
            '&' => resultat.push_str("&amp;"),
            _ => resultat.push(caractere),
        }
    }
    resultat
}

/// 🖼️ Analyse binaire stricte des signatures d'images (Magic Numbers)
pub fn valider_format_image(octets: &[u8]) -> bool {
    if octets.len() < 4 {
        return false;
    }
    // Vérification magique : JPEG (FF D8 FF) ou PNG (89 50 4E 47)
    let jpeg = octets[0] == 0xFF && octets[1] == 0xD8 && octets[2] == 0xFF;
    let png = octets[0] == 0x89 && octets[1] == 0x50 && octets[2] == 0x4E && octets[3] == 0x47;
    
    jpeg || png
}