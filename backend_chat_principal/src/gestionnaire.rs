use axum::{extract::ws::{Message, WebSocket, WebSocketUpgrade}, extract::State, response::IntoResponse};
use futures_util::{sink::SinkExt, stream::StreamExt};
use tokio::sync::mpsc;
use std::sync::Arc;

use crate::protocole::PaquetYrion;
use crate::securite::assainir_identifiant;
use crate::AppStateYrion; // 🛰️ Récupération de l'état global combiné depuis la racine

// Importation propre de tes 5 micro-moteurs indépendants
use crate::message_normal;
use crate::modifier_message;
use crate::message_vocal;
use crate::appel_normal;
use crate::appel_video;

// Extraction propre de l'état avec le type explicite partagé avec main.rs
pub async fn point_entree_liaison(
    ws: WebSocketUpgrade, 
    State(etat): State<Arc<AppStateYrion>> // 🧠 État étendu contenant le noyau et les notifs
) -> impl IntoResponse {
    ws.on_upgrade(move |socket| traiter_pipeline(socket, etat))
}

async fn traiter_pipeline(socket: WebSocket, etat: Arc<AppStateYrion>) {
    let (mut expediteur_ws, mut recepteur_ws) = socket.split();
    let (tx, mut rx) = mpsc::unbounded_channel();

    tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if expediteur_ws.send(msg).await.is_err() { break; }
        }
    });

    let mut id_astronaute_verifie: Option<String> = None;
    
    // Raccourcis propres vers tes deux structures en RAM sans altérer ton code
    let registre = &etat.noyau_central;
    let notifs_actifs = &etat.notifs_actifs;

    while let Some(Ok(message_brut)) = recepteur_ws.next().await {
        if let Message::Text(corps_texte) = message_brut {
            if let Ok(paquet) = serde_json::from_str::<PaquetYrion>(&corps_texte) {
                match paquet {
                    PaquetYrion::EnregistrerAstronaute { user_id } => {
                        if let Some(id_propre) = assainir_identifiant(&user_id) {
                            id_astronaute_verifie = Some(id_propre.clone());
                            
                            // 🔒 TA LOGIQUE INCHANGÉE (Chat principal)
                            let mut memoire = registre.write().await;
                            memoire.astronautes_actifs.insert(id_propre.clone());
                            memoire.terminaux.insert(id_propre.clone(), tx.clone());
                            
                            // 🛰️ MISE À JOUR : Enregistrement simultané dans le dictionnaire des notifications
                            let mut memoire_notifs = notifs_actifs.write().await;
                            memoire_notifs.insert(id_propre, tx.clone());
                        } else { break; }
                    }

                    PaquetYrion::MessageTexte { id, expediteur_id, destinataire_id, contenu } => {
                        message_normal::gerer_texte(id, expediteur_id, destinataire_id, contenu, registre, notifs_actifs, &tx).await;
                    }

                    PaquetYrion::ModifierMessage { id_message, expediteur_id, destinataire_id, nouveau_contenu } => {
                        if let Some(ref unique_id) = id_astronaute_verifie {
                            // 🎯 BIEN JOUÉ : Maintenant, la modification prend en compte "notifs_actifs" pour mettre à jour la bulle Flutter !
                            modifier_message::gerer_modification(id_message, expediteur_id, destinataire_id, nouveau_contenu, registre, unique_id, notifs_actifs).await;
                        }
                    }

                    PaquetYrion::MessageVocal { id, expediteur_id, destinataire_id, url_audio, duree_secondes } => {
                        message_vocal::gerer_vocal(id, expediteur_id, destinataire_id, url_audio, duree_secondes, registre, notifs_actifs).await;
                    }

                    PaquetYrion::AppelNormal { emetteur_id, recepteur_id, etape, sdp } => {
                        appel_normal::gerer_appel_audio(emetteur_id, recepteur_id, etape, sdp, registre, notifs_actifs).await;
                    }

                    PaquetYrion::AppelVideo { emetteur_id, recepteur_id, etape, sdp } => {
                        appel_video::gerer_appel_video(emetteur_id, recepteur_id, etape, sdp, registre, notifs_actifs).await;
                    }
                    _ => {}
                }
            }
        }
    }

    // 🔌 Déconnexion : Nettoyage chirurgical des deux côtés pour éviter toute fuite RAM
    if let Some(user_id) = id_astronaute_verifie {
        let mut memoire = registre.write().await;
        memoire.astronautes_actifs.remove(&user_id);
        memoire.terminaux.remove(&user_id);
        
        let mut memoire_notifs = notifs_actifs.write().await;
        memoire_notifs.remove(&user_id);
    }
} 

// mise ajoour niveau 2