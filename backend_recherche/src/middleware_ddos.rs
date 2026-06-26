use axum::{
    middleware::Next,
    response::Response,
    extract::Request,
    http::StatusCode,
};
use tower::Layer;   
use tower::Service; 
use crate::securite::bouclier_anti_ddos;

/// 🚀 ENVELOPPE CLONABLE PERFORMANCE MAXIMALE
/// Intercepte, applique la régulation de trafic du bouclier, et transmet au routeur.
pub async fn appliquer_protection_ddos(request: Request, next: Next) -> Result<Response, StatusCode> {
    let limiteur = bouclier_anti_ddos();
    
    // 🛠️ FIX CRITIQUE : Ajout de `move` et `.clone()` pour valider le trait `FnMut`
    let service_interne = tower::service_fn(move |req: Request| {
        let next = next.clone();
        async move {
            Ok::<Response, std::convert::Infallible>(next.run(req).await)
        }
    });
    
    // Correction de la tuyauterie : Le layer enveloppe le service interne
    let mut service_ordonnance = limiteur.layer(service_interne);
    
    // Remplacement du match par un if let pour contourner définitivement l'erreur E0004
    if let Ok(reponse) = service_ordonnance.call(request).await {
        Ok(reponse)
    } else {
        Err(StatusCode::TOO_MANY_REQUESTS)
    }
}

//mise a jour 