// src/notifications/dispatcher.rs
use axum::extract::ws::Message;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::sync::mpsc;
use std::time::{SystemTime, UNIX_EPOCH};
use crate::notifications::protocole::{
    PaquetNotificationQuantique, ActeurNotif, TypeEvenement, PhaseParcours, ModeRoutage
};

pub type TransmissionNotifMap = Arc<RwLock<HashMap<String, mpsc::UnboundedSender<Message>>>>;

/// Propulse la notification avec le protocole d'accélération d'Yrion Core
pub async fn propulser_notification(
    destinataire_id: String,
    expediteur: ActeurNotif,
    type_evt: TypeEvenement,
    contenu_brut: String,
    cible_id: Option<String>,
    utilisateurs_actifs: TransmissionNotifMap,
) {
    let id_notification_unique = uuid::Uuid::new_v4().to_string();
    
    // Mode Super-Sonique activé automatiquement pour les appels
    let mode = match type_evt {
        TypeEvenement::AppelNormal | TypeEvenement::AppelVideo => ModeRoutage::SuperSonique,
        _ => ModeRoutage::Standard,
    };

    let (message_formate, bouton) = match type_evt {
        TypeEvenement::Texte => (contenu_brut, None),
        TypeEvenement::Vocal => (format!("vous a envoyé un message vocal"), Some("Écouter".to_string())),
        TypeEvenement::AppelNormal => (format!("Liaison audio entrante..."), Some("Répondre".to_string())),
        TypeEvenement::AppelVideo => (format!("Liaison vidéo entrante..."), Some("Rejoindre".to_string())),
    };

    let temps_ns = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_nanos();

    let mut paquet = PaquetNotificationQuantique {
        notification_id: id_notification_unique,
        type_evenement: type_evt,
        phase: PhaseParcours::Initialisation,
        mode,
        acteur: expediteur,
        message_apercu: message_formate,
        bouton_action: bouton,
        cible_id,
        horodatage_ns: temps_ns,
    };

    let phases = vec![
        PhaseParcours::Initialisation,
        PhaseParcours::Encoding,
        PhaseParcours::Dispatch,
        PhaseParcours::Livraison,
        PhaseParcours::Activation,
    ];

    for phase in phases {
        paquet.phase = phase;
        
        // Sérialisation optimisée en chaîne compacte
        if let Ok(json_texte) = serde_json::to_string(&paquet) {
            let mut envoye = false;
            
            // Verrouillage ultra-court de la RAM pour ne pas ralentir le serveur
            {
                let sockets = utilisateurs_actifs.read().await;
                if let Some(tx) = sockets.get(&destinataire_id) {
                    if tx.send(Message::Text(json_texte)).is_ok() {
                        envoye = true;
                    }
                }
            }

            // Si le destinataire a une micro-coupure, on met en pause le défilement pour l'attendre
            if !envoye && mode == ModeRoutage::Standard {
                tokio::time::sleep(tokio::time::Duration::from_millis(150)).await;
                continue;
            }
        }

        // Gestion du timing de l'animation selon l'urgence
        let delai_ms = match mode {
            ModeRoutage::SuperSonique => 30, // L'OVNI traverse l'écran à la vitesse de la lumière pour un appel !
            ModeRoutage::Standard => 100,    // Transition fluide et ultra-satisfaisante pour un message
        };
        
        tokio::time::sleep(tokio::time::Duration::from_millis(delai_ms)).await;
    }
}

// miser a jou rniveaux 1