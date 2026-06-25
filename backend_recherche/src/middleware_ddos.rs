use axum::{
    middleware::Next,
    response::Response,
    extract::Request,
    http::StatusCode,
};
use tower::Service;
use crate::securite::bouclier_anti_ddos;

/// 🚀 ENVELOPPE CLONABLE PERFORMANCE MAXIMALE
/// Intercepte, applique la régulation de trafic du bouclier, et transmet au routeur.
pub async fn appliquer_protection_ddos(request: Request, next: Next) -> Result<Response, StatusCode> {
    let mut limiteur = bouclier_anti_ddos();
    
    // Encapsulation légère de la suite du pipeline Axum
    let service_interne = tower::service_fn(|req: Request| async move {
        Ok::<Response, std::convert::Infallible>(next.run(req).await)
    });
    
    let mut service_ordonnance = limiteur.call(service_interne);
    
    match service_ordonnance.call(request).await {
        Ok(reponse) => Ok(reponse),
        Err(_) => Err(StatusCode::TOO_MANY_REQUESTS),
    }
}