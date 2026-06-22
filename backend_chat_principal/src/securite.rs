use std::time::{Duration, Instant};
use std::collections::HashMap;
use std::sync::{Mutex, OnceLock};
use axum::{
    extract::Request,
    middleware::Next,
    response::{IntoResponse, Response},
    http::StatusCode,
};

// 💡 CORRECTION : Permet de désactiver l'avertissement jaune de code mort avant son utilisation complète
#[allow(dead_code)]
pub struct RadarSecurite {
    pub historique_frappes: Mutex<HashMap<String, u32>>,
}

#[allow(dead_code)]
impl RadarSecurite {
    pub fn initialiser() -> Self {
        Self {
            historique_frappes: Mutex::new(HashMap::new()),
        }
    }

    pub fn verifier_frequentation(&self, cible_id: &str) -> bool {
        if let Ok(mut memoire_radar) = self.historique_frappes.lock() {
            let compteur = memoire_radar.entry(cible_id.to_string()).or_insert(0);
            *compteur += 1;
            if *compteur > 150 {
                return false; 
            }
        }
        true
    }
}

/// 🛡️ BOUCLIER DDOS RESEAU COMPATIBLE AXUM 0.7
/// Limite stricte des requêtes à la volée. Rentre parfaitement dans les critères de clonage.
pub async fn bouclier_anti_ddos(request: Request, next: Next) -> Response {
    static COMPTEUR_GLOBAL: OnceLock<Mutex<(Instant, u32)>> = OnceLock::new();
    
    let mutex_global = COMPTEUR_GLOBAL.get_or_init(|| {
        Mutex::new((Instant::now(), 0))
    });
    
    let maintenant = Instant::now();
    if let Ok(mut lock) = mutex_global.lock() {
        if maintenant.duration_since(lock.0) > Duration::from_secs(1) {
            lock.0 = maintenant;
            lock.1 = 0;
        }
        lock.1 += 1;
        
        // Seuil : maximum 30 requêtes par seconde
        if lock.1 > 30 {
            return (
                StatusCode::TOO_MANY_REQUESTS,
                "Trop de requêtes, zone temporairement protégée.",
            ).into_response();
        }
    }

    next.run(request).await
}

/// 🔐 INSPECTEUR SÉCURITÉ DE ZONE
pub fn assainir_identifiant(id: &str) -> Option<String> {
    if id.len() > 40 || id.trim().is_empty() { return None; }
    let filtre: String = id.chars().filter(|c| c.is_alphanumeric() || *c == '_').collect();
    if filtre.is_empty() { None } else { Some(filtre) }
}

#[allow(dead_code)]
pub fn valider_texte(contenu: &str) -> Option<String> {
    const LIMITE_OCTETS: usize = 4000;
    if contenu.len() > LIMITE_OCTETS || contenu.contains("<script>") {
        return None;
    }
    Some(contenu.to_string())
}

//mmise ajour 1