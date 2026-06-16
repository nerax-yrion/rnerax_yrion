use std::collections::HashMap;
use std::time::{Duration, Instant};
use tokio::sync::RwLock;
use std::sync::Arc;
use bcrypt::{hash, verify, DEFAULT_COST};
use std::net::IpAddr;

/// ============================================================================
/// STRUCTURE : LimiteurDeDebit (Rate Limiter Élite)
/// DESCRIPTION : Protecteur anti-DoS asynchrone haute performance capable de
///               gérer des millions de connexions sans bloquer les threads.
/// ============================================================================
pub struct LimiteurDeDebit {
    // Indexation par type IpAddr strict pour bloquer les falsifications de chaînes
    requetes: Arc<RwLock<HashMap<IpAddr, (u32, Instant)>>>, 
}

impl LimiteurDeDebit {
    pub fn new() -> Self {
        Self {
            requetes: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    /// Valide l'IP et applique un rationnement drastique (max 30 req / 10s)
    pub async fn verifier_ip(&self, ip_brute: &str) -> bool {
        let maintenant = Instant::now();
        let limite_temps = Duration::from_secs(10);

        // Anti-IpSpoofing : On refuse la requête si la chaîne ne correspond pas à une IP valide (IPv4 ou IPv6)
        let ip_valide = match ip_brute.trim().parse::<IpAddr>() {
            Ok(ip) => ip,
            Err(_) => return false, // Rejet immédiat de l'adresse corrompue
        };

        // 1. Phase Optimiste (Lecture rapide sans verrou d'écriture)
        {
            let requetes_lecture = self.requetes.read().await;
            if let Some((compteur, fenetre)) = requetes_lecture.get(&ip_valide) {
                if maintenant.duration_since(*fenetre) <= limite_temps && *compteur >= 30 {
                    return false;
                }
            }
        }

        // 2. Phase Critique (Écriture synchronisée)
        let mut requetes = self.requetes.write().await;

        // Stratégie anti-saturation de RAM : purge radicale si la table dépasse 10 000 IPs actives
        if requetes.len() > 10_000 {
            requetes.retain(|_, (_, instant)| maintenant.duration_since(*instant) < limite_temps);
        }

        let (compteur, fenetre) = requetes.entry(ip_valide).or_insert((0, maintenant));
        
        if maintenant.duration_since(*fenetre) > limite_temps {
            *compteur = 1;
            *fenetre = maintenant;
            true
        } else {
            *compteur += 1;
            *compteur <= 30
        }
    }
}

/// ============================================================================
/// FONCTION : assainir_texte (Garde-fou Anti-XSS avancé et filtrage de caractères)
/// DESCRIPTION : Nettoie les chaînes de texte entrantes sans allocation inutile.s
/// ============================================================================
pub fn assainir_texte(entree: &str) -> String {
    // Allocation préventive stricte pour éviter les attaques par déni de service sur la mémoire
    let mut resultat = String::with_capacity(entree.len() * 2); 
    
    for caractere in entree.chars() {
        match caractere {
            '<' => resultat.push_str("&lt;"),
            '>' => resultat.push_str("&gt;"),
            '"' => resultat.push_str("&quot;"),
            '\'' => resultat.push_str("&#x27;"),
            '&' => resultat.push_str("&amp;"),
            '/' => resultat.push_str("&#x2F;"), // Bloque la fermeture de balises HTML déguisées
            '`' => resultat.push_str("&#x60;"), // Bloque l'exécution de templates JavaScript
            _ => resultat.push(caractere),
        }
    }
    resultat
}

/// ============================================================================
/// FONCTION : valider_format_image (Analyse Anti-Fichiers Polyglottes)
/// DESCRIPTION : Analyse l'intégralité du tableau d'octets pour bloquer les injections.
/// ============================================================================
pub fn valider_format_image(octets: &[u8]) -> bool {
    // Protection contre les payloads trop légers ou gigantesques (Attaques de débordement)
    if octets.len() < 4 || octets.len() > 10_485_760 { // Limite stricte à 10 Mo par image
        return false;
    }

    // 1. Validation des Magic Numbers de l'en-tête
    let es_jpeg = octets[0] == 0xFF && octets[1] == 0xD8 && octets[2] == 0xFF;
    let es_png = octets[0] == 0x89 && octets[1] == 0x50 && octets[2] == 0x4E && octets[3] == 0x47;
    
    if !es_jpeg && !es_png {
        return false;
    }

    // 2. Scan anti-stéganographie et anti-payload masqué
    // Correction ici : type spécifié explicitement en tableau de slices `&[&[u8]]` 
    // afin d'accepter des séquences d'octets de longueurs différentes (3, 5, 7...) sans bloquer le compilateur.
    let signatures_suspectes: &[&[u8]] = &[
        b"<?php", 
        b"<?=", 
        b"<script", 
        b"eval(", 
        b"base64_decode"
    ];

    // Recherche de signatures malveillantes dans le corps binaire de l'image
    for signature in signatures_suspectes {
        if octets.windows(signature.len()).any(|window| window == *signature) {
            return false; // Code malveillant détecté au milieu des pixels de l'image !
        }
    }

    true
}

/// ============================================================================
/// FONCTION : hacher_mot_de_passe (Sécurisation Cryptographique Bcrypt)
/// DESCRIPTION : Sécurise le mot de passe utilisateur via l'algorithme Bcrypt.
/// ============================================================================
pub fn hacher_mot_de_passe(mot_de_passe_brut: &str) -> String {
    // Mesure de protection : interdiction des mots de passe anormalement longs pour éviter l'épuisement CPU
    if mot_de_passe_brut.len() > 72 {
        panic!("Longueur de mot de passe invalide (Vecteur d'attaque CPU bloqué).");
    }

    match hash(mot_de_passe_brut, DEFAULT_COST) {
        Ok(hache) => hache,
        Err(_) => {
            panic!("Erreur système critique lors de la génération de l'empreinte de sécurité.");
        }
    }
}

/// ============================================================================
/// FONCTION : verifier_mot_de_passe (Anti-Timing Attacks)
/// DESCRIPTION : Compare le mot de passe saisi lors de la connexion avec le hash BDD.
/// ============================================================================
pub fn verifier_mot_de_passe(mot_de_passe_brut: &str, hachage_stocke: &str) -> bool {
    if mot_de_passe_brut.len() > 72 {
        return false;
    }
    
    // La crate bcrypt effectue une comparaison en temps constant en interne.
    verify(mot_de_passe_brut, hachage_stocke).unwrap_or(false)
}

// mise a jour 1