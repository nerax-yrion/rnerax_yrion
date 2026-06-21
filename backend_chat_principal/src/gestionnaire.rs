use axum::{extract::ws::{Message, WebSocket, WebSocketUpgrade}, extract::State, response::IntoResponse};
use futures_util::{sink::SinkExt, stream::StreamExt};
use tokio::sync::mpsc;

use crate::protocole::PaquetYrion;
use crate::registre::RegistrePartage;
use crate::securite::assainir_identifiant;

// Importation de nos 5 micro-moteurs indépendants
mod message_normal;
mod modifier_message;
mod message_vocal;
mod appel_normal;
mod appel_video;

pub async fn point_entree_liaison(ws: WebSocketUpgrade, State(registre): State<RegistrePartage>) -> impl IntoResponse {
    ws.on_upgrade(move |socket| traiter_pipeline(socket, registre))
}

async fn traiter_pipeline(socket: WebSocket, registre: RegistrePartage) {
    let (mut expediteur_ws, mut recepteur_ws) = socket.split();
    let (tx, mut rx) = mpsc::unbounded_channel();

    tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if expediteur_ws.send(msg).await.is_err() { break; }
        }
    });

    let mut id_astronaute_verifie: Option<String> = None;

    while let Some(Ok(message_brut)) = recepteur_ws.next().await {
        if let Message::Text(corps_texte) = message_brut {
            if let Ok(paquet) = serde_json::from_str::<PaquetYrion>(&corps_texte) {
                match paquet {
                    PaquetYrion::EnregistrerAstronaute { user_id } => {
                        if let Some(id_propre) = assainir_identifiant(&user_id) {
                            id_astronaute_verifie = Some(id_propre.clone());
                            let mut memoire = registre.write().await;
                            memoire.astronautes_actifs.insert(id_propre.clone());
                            memoire.terminaux.insert(id_propre, tx.clone());
                        } else { break; }
                    }

                    PaquetYrion::MessageTexte { id, expediteur_id, destinataire_id, contenu } => {
                        message_normal::gerer_texte(id, expediteur_id, destinataire_id, contenu, &registre, &tx).await;
                    }

                    PaquetYrion::ModifierMessage { id_message, expediteur_id, destinataire_id, nouveau_contenu } => {
                        if let Some(ref unique_id) = id_astronaute_verifie {
                            modifier_message::gerer_modification(id_message, expediteur_id, destinataire_id, nouveau_contenu, &registre, unique_id).await;
                        }
                    }

                    PaquetYrion::MessageVocal { id, expediteur_id, destinataire_id, url_audio, duree_secondes } => {
                        message_vocal::gerer_vocal(id, expediteur_id, destinataire_id, url_audio, duree_secondes, &registre).await;
                    }

                    PaquetYrion::AppelNormal { emetteur_id, recepteur_id, etape, sdp } => {
                        appel_normal::gerer_appel_audio(emetteur_id, recepteur_id, etape, sdp, &registre).await;
                    }

                    PaquetYrion::AppelVideo { emetteur_id, recepteur_id, etape, sdp } => {
                        appel_video::gerer_appel_video(emetteur_id, recepteur_id, etape, sdp, &registre).await;
                    }
                    _ => {}
                }
            }
        }
    }

    if let Some(user_id) = id_astronaute_verifie {
        let mut memoire = registre.write().await;
        memoire.astronautes_actifs.remove(&user_id);
        memoire.terminaux.remove(&user_id);
    }
}