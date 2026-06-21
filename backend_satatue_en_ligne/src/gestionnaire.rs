use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    extract::State,
    response::IntoResponse,
};
use futures_util::{sink::SinkExt, stream::StreamExt};
use tokio::sync::mpsc;
use crate::protocole::PaquetPresence;
use crate::securite::nettoyer_identifiant;
use crate::registre::{diffuser_statut_galaxie, RegistrePartage};

pub async fn tunnel_websocket_presence(
    ws: WebSocketUpgrade,
    State(registre): State<RegistrePartage>,
) -> impl IntoResponse {
    ws.on_upgrade(move |socket| traiter_flux_quantique(socket, registre))
}

async fn traiter_flux_quantique(socket: WebSocket, registre: RegistrePartage) {
    let (mut expediteur_ws, mut recepteur_ws) = socket.split();
    let (tx, mut rx) = mpsc::unbounded_channel();

    // Tâche d'envoi asynchrone (Pipeline d'écriture)
    tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if expediteur_ws.send(msg).await.is_err() {
                break;
            }
        }
    });

    let mut id_astronaute_local: Option<String> = None;

    // Boucle d'écoute sécurisée
    while let Some(Ok(message_brut)) = recepteur_ws.next().await {
        if let Message::Text(corps_texte) = message_brut {
            if let Ok(paquet) = serde_json::from_str::<PaquetPresence>(&corps_texte) {
                match paquet {
                    PaquetPresence::EnregistrerAstronaute { user_id } => {
                        // 🔐 SÉCURITÉ EN ACTION : On filtre le nom avant de faire quoi que ce soit
                        if let Some(nom_securise) = nettoyer_identifiant(&user_id) {
                            id_astronaute_local = Some(nom_securise.clone());
                            
                            let mut memoire = registre.write().await;
                            memoire.utilisateurs_actifs.insert(nom_securise.clone());
                            memoire.sessions.insert(nom_securise.clone(), tx.clone());
                            
                            println!("🟢 [Sécurisé] En ligne : {}", nom_securise);
                            diffuser_statut_galaxie(&memoire, nom_securise, true);
                        } else {
                            println!("⚠️ [Alerte Sécurité] Tentative d'injection bloquée !");
                            break; // Coupe immédiatement la liaison radio du suspect
                        }
                    }
                    _ => {}
                }
            }
        }
    }

    // Nettoyage automatique à la fermeture
    if let Some(user_id) = id_astronaute_local {
        let mut memoire = registre.write().await;
        memoire.utilisateurs_actifs.remove(&user_id);
        memoire.sessions.remove(&user_id);
        
        println!("🔴 [Sécurisé] Hors ligne : {}", user_id);
        diffuser_statut_galaxie(&memoire, user_id, false);
    }
}