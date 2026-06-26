use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    extract::State,
    response::IntoResponse,
};
use futures_util::{sink::SinkExt, stream::StreamExt};
use std::sync::Arc;
use tokio::sync::mpsc;
use sqlx::PgPool; // 👈 AJOUT CRUCIAL : Importation du type Pool pour Neon

use crate::moteur_recherche;
use crate::protocole::PaquetRecherche;
use crate::registre::RegistrePartage;

// ⚡ RESTRUCTURATION DE L'ÉTAT COMPOSITE D'YRION (HAUTE DISPONIBILITÉ)
// Regroupe le registre RAM et le pool SQL pour une injection propre via l'Extracteur Axum
pub struct EtatRecherche {
    pub registre: RegistrePartage,
    pub pool_neon: PgPool,
}
pub type EtatRecherchePartage = Arc<EtatRecherche>;

pub async fn point_entree_recherche(
    ws: WebSocketUpgrade,
    State(etat): State<EtatRecherchePartage>, // 👈 CHANGEMENT STRATÉGIQUE : On passe l'état partagé global
) -> impl IntoResponse {
    // Surclassement immédiat vers WebSocket avec configuration mémoire optimale
    ws.on_upgrade(move |socket| traiter_flux_recherche_securise(socket, etat))
}

async fn traiter_flux_recherche_securise(socket: WebSocket, etat: EtatRecherchePartage) {
    let (mut expediteur_ws, mut recepteur_ws) = socket.split();
    
    // Canal atomique à allocation optimisée (Unbounded pour une latence à 0ms)
    let (tx, mut rx) = mpsc::unbounded_channel::<Message>();

    // 🚀 OPTIMISATION 1 : Tâche d'envoi autonome en tâche de fond
    tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if expediteur_ws.send(msg).await.is_err() {
                break;
            }
        }
    });

    // Enveloppe de l'émetteur pour la distribution parallèle des paquets
    let tx_partage = Arc::new(tx);

    // Écoute active et traitement non-bloquant du flux asynchrone
    while let Some(Ok(message_brut)) = recepteur_ws.next().await {
        if let Message::Text(corps_texte) = message_brut {
            if let Ok(paquet) = serde_json::from_str::<PaquetRecherche>(&corps_texte) {
                match paquet {
                    // Synchronisation asynchrone locale dans la RAM du catalogue si besoin
                    PaquetRecherche::AlimenterCatalogue { user_id } => {
                        let mut ecriture = etat.registre.write().await;
                        ecriture.base_pseudos.insert(user_id);
                    }

                    // 🛸 RECHERCHE FLOUE QUANTIQUE (IMMUNITÉ AUX FAUTES DE FRAPPE & ZÉRO CONFLIT)
                    PaquetRecherche::LancerRecherche { requete } => {
                        let pool_clone = etat.pool_neon.clone(); // Le clonage d'un PgPool est ultra-léger (Arc interne)
                        let tx_clone = Arc::clone(&tx_partage);
                        
                        // Chaque frappe de l'utilisateur génère un thread vert Tokio indépendant.
                        // Même si l'utilisateur tape à une vitesse folle, Neon résout la requête floue
                        // en parallèle sans jamais ralentir le reste de l'application Flutter.
                        tokio::spawn(async move {
                            moteur_recherche::executer_filtrage_quantique(requete, &pool_clone, &tx_clone).await;
                        });
                    }

                    // 🛡️ EXHAUSTIVITÉ STRICTE : Cas de bouclage ignoré en toute sécurité
                    PaquetRecherche::ResultatsFiltres { .. } => {}
                }
            }
        }
    }
    
    // Nettoyage atomique automatique lors de la déconnexion
}

// mise a jour du fichier gestionnaire version 2 - ÉDITION FINALE ÉLITE