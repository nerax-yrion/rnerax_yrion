use axum::{
    extract::Request,
    middleware::Next,
    response::{IntoResponse, Response},
    http::StatusCode,
};
use std::sync::Mutex;
use std::time::{Duration, Instant};
use std::collections::HashMap;

// Structure interne pour suivre les requêtes par IP ou par connexion
struct CompteurDdos {
    dernier_acces: Instant,
    nombre_requetes: u32,
}

lazy_static::lazy_static! {
    static ref MEMOIRE_DDOS: Mutex<HashMap<String, CompteurDdos>> = Mutex::new(HashMap::new());
}

/// 🛡️ BOUCLIER SÉCURITÉ MATÉRIEL NATIF
/// Autorise un maximum de 30 requêtes par seconde. Rejette immédiatement l'excédent.
pub async fn intercepteur_anti_ddos(request: Request, next: Next) -> Response {
    // On récupère une clé unique pour l'appelant (ou une valeur générique par défaut)
    let adresse_client = request
        .headers()
        .get("x-forwarded-for")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("client_unique")
        .to_string();

    let maintenant = Instant::now();
    let mut memoire = MEMOIRE_DDOS.lock().unwrap();
    let donnees = memoire.entry(adresse_client).or_insert(CompteurDdos {
        dernier_acces: maintenant,
        nombre_requetes: 0,
    });

    // Si plus d'une seconde s'est écoulée, on réinitialise le compteur
    if maintenant.duration_since(donnees.dernier_acces) > Duration::from_secs(1) {
        donnees.nombre_requetes = 0;
        donnees.dernier_acces = maintenant;
    }

    donnees.nombre_requetes += 1;

    // Seuil strict : 30 requêtes par seconde maximum
    if donnees.nombre_requetes > 30 {
        return (
            StatusCode::TOO_MANY_REQUESTS,
            "Trop de requêtes, zone temporairement protégée.",
        )
            .into_response();
    }

    // Si tout est correct, on laisse passer au gestionnaire principal
    next.run(request).await
}