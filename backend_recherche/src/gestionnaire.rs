use axum::{extract::ws::{Message, WebSocket, WebSocketUpgrade}, extract::State, response::IntoResponse};
use futures_util::{sink::SinkExt, stream::StreamExt};
use tokio::sync::mpsc;

use crate::protocole::PaquetRecherche;
use crate::registre::RegistrePartage;
use crate::moteur_recherche;

pub async fn point_entree_recherche(
    ws: WebSocketUpgrade,
    State(registre): State<RegistrePartage>,
) -> impl IntoResponse {
    // Surclassement de la connexion HTTP standard vers le protocole sécurisé WebSocket
    ws.on_upgrade(move |socket| traiter_flux_recherche_securise(socket, registre))
}

async fn traiter_flux_recherche_securise(socket: WebSocket, registre: RegistrePartage) {
    let (mut expediteur_ws, mut recepteur_ws) = socket.split();
    let (tx, mut rx) = mpsc::unbounded_channel();

    // Tâche asynchrone isolée pour l'envoi de données (Évite les blocages de flux)
    tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if expediteur_ws.send(msg).await.is_err() {
                break;
            }
        }
    });

    // Écoute et exécution des requêtes de recherche
    while let Some(Ok(message_brut)) = recepteur_ws.next().await {
        if let Message::Text(corps_texte) = message_brut {
            if let Ok(paquet) = serde_json::from_str::<PaquetRecherche>(&corps_texte) {
                match paquet {
                    // Synchronisation sécurisée des utilisateurs dans la RAM du serveur de recherche
                    PaquetRecherche::AlimenterCatalogue { user_id } => {
                        let mut ecriture = registre.write().await;
                        ecriture.base_pseudos.insert(user_id);
                    }

                    // Déclenchement instantané de l'algorithme de recherche
                    PaquetRecherche::LancerRecherche { requete } => {
                        moteur_recherche::executer_filtrage_quantique(requete, &registre, &tx).await;
                    }
                }
            }
        }
    }
}