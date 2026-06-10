use axum::{
    http::{header, HeaderValue, Method, StatusCode},
    middleware::{self, Next},
    response::IntoResponse,
    Router,
};
use std::{net::SocketAddr, time::Duration};
use tower_http::{cors::CorsLayer, trace::TraceLayer};

/// ⏱️ MIDDLEWARE DE TIMEOUT NATIF : Coupe proprement les requêtes trop lentes
async fn filtrer_timeout(req: axum::http::Request<axum::body::Body>, next: Next) -> impl IntoResponse {
    // On lance la requête et on l'interrompt si elle dépasse 5 secondes
    match tokio::time::timeout(Duration::from_secs(5), next.run(req)).await {
        Ok(reponse) => reponse,
        Err(_) => (
            StatusCode::REQUEST_TIMEOUT,
            "⚠️ Timeout réseau : La requête a mis trop de temps à répondre.".to_string(),
        ).into_response(),
    }
}

/// Lance l'écoute réseau sur le port 5000
pub async fn demarrer(routes_api: Router) {
    // 1. Configuration du Pare-feu CORS
    let cors = CorsLayer::new()
        .allow_origin("*".parse::<HeaderValue>().unwrap())
        .allow_methods([Method::GET, Method::POST])
        .allow_headers([header::CONTENT_TYPE, header::AUTHORIZATION]);

    // 2. Assemblage de l'application (Zéro gymnastique de types compliqués)
    let application = Router::new()
        .nest("/api/v1", routes_api)
        .layer(cors)
        .layer(TraceLayer::new_for_http())
        .layer(middleware::from_fn(filtrer_timeout)); // Injection propre et stable

    // 3. Démarrage de l'infrastructure
    let adresse = SocketAddr::from(([0, 0, 0, 0], 5000));
    tracing::info!("🛰️ Serveur Yrion actif sur : http://localhost:5000");
    
    let ecouteur = tokio::net::TcpListener::bind(&adresse).await.unwrap();
    axum::serve(ecouteur, application).await.unwrap();
}

//1