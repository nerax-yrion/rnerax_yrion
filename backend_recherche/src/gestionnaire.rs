use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    extract::State,
    response::IntoResponse,
};
use futures_util::{sink::SinkExt, stream::StreamExt};
use std::sync::Arc;
use tokio::sync::mpsc;

use crate::moteur_recherche;
use crate::protocole::PaquetRecherche;
use crate::registre::RegistrePartage;

pub async fn point_entree_recherche(
    ws: WebSocketUpgrade,
    State(registre): State<RegistrePartage>,
) -> impl IntoResponse {
    // Surclassement immédiat vers WebSocket avec configuration mémoire optimale
    ws.on_upgrade(move |socket| traiter_flux_recherche_securise(socket, registre))
}

async fn traiter_flux_recherche_securise(socket: WebSocket, registre: RegistrePartage) {
    let (mut expediteur_ws, mut recepteur_ws) = socket.split();
    
    // Canal atomique à allocation optimisée
    let (tx, mut rx) = mpsc::unbounded_channel::<Message>();

    // 🚀 OPTIMISATION 1 : Tâche d'envoi autonome qui meurt proprement dès que `tx` ou la socket lâche
    tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if expediteur_ws.send(msg).await.is_err() {
                break;
            }
        }
    });

    // On enveloppe l'émetteur dans un Arc pour permettre des recherches parallèles ultra-rapides
    let tx_partage = Arc::new(tx);

    // Écoute active et traitement non-bloquant des requêtes entrantes
    while let Some(Ok(message_brut)) = recepteur_ws.next().await {
        if let Message::Text(corps_texte) = message_brut {
            if let Ok(paquet) = serde_json::from_str::<PaquetRecherche>(&corps_texte) {
                match paquet {
                    // Synchronisation asynchrone dans la RAM du catalogue de recherche
                    PaquetRecherche::AlimenterCatalogue { user_id } => {
                        let mut ecriture = registre.write().await;
                        ecriture.base_pseudos.insert(user_id);
                    }

                    // 🚀 OPTIMISATION 2 : Exécution de la recherche en concurrence asynchrone
                    // L'utilisation de tokio::spawn ici empêche un utilisateur qui tape trop vite 
                    // de bloquer sa propre socket. Chaque recherche tourne sur son propre thread vert.
                    PaquetRecherche::LancerRecherche { requete } => {
                        let registre_clone = registre.clone();
                        let tx_clone = Arc::clone(&tx_partage);
                        
                        tokio::spawn(async move {
                            moteur_recherche::executer_filtrage_quantique(requete, &registre_clone, &tx_clone).await;
                        });
                    }

                    // 🛡️ EXHAUSTIVITÉ STRICTE : Cas de bouclage ignoré en toute sécurité
                    PaquetRecherche::ResultatsFiltres { .. } => {}
                }
            }
        }
    }
    
    // Au sortir de la boucle, `recepteur_ws` et `tx_partage` sont détruits naturellement.
    // Le canal se ferme proprement, ce qui met fin à la tâche d'envoi automatiquement sans gaspiller de CPU.
}

// mise a jour du fichier gestionnair version 1