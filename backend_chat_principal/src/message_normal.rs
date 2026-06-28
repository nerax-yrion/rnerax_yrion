use crate::protocole::PaquetYrion;
use crate::registre::{envoyer_direct, RegistrePartage};
use crate::securite::valider_texte;
use axum::extract::ws::Message;
use tokio::sync::mpsc;

// 🛰️ Imports requis pour le module de notifications quantiques
use crate::notifications::protocole::{ActeurNotif, TypeEvenement};
use crate::notifications::dispatcher::TransmissionNotifMap;

pub async fn gerer_texte(
    id: String, expediteur: String, destinataire: String, contenu: String,
    registre: &RegistrePartage, 
    notifs_actifs: &TransmissionNotifMap, // 👈 Ajouté pour connecter la RAM de notifications
    tx: &mpsc::UnboundedSender<Message>
) {
    if let Some(texte_sain) = valider_texte(&contenu) {
        let paquet = PaquetYrion::MessageTexte {
            id: id.clone(), expediteur_id: expediteur.clone(), destinataire_id: destinataire.clone(), contenu: texte_sain.clone(),
        };
        
        let livre = envoyer_direct(registre, &destinataire, &paquet).await;
        let confirmation = PaquetYrion::ChangementStatut {
            message_id: id,
            etat: if livre { "recu".to_string() } else { "envoye".to_string() },
        };
        let _ = tx.send(Message::Text(serde_json::to_string(&confirmation).unwrap()));

        // =====================================================================
        // 🚀 AMÉLIORATION ÉLITE D'YRION : PROPULSION DE LA NOTIFICATION FLUTTER
        // =====================================================================
        let acteur = ActeurNotif {
            user_id: expediteur,
            username: "Ami Yrion".to_string(), 
            profile_image_url: None, 
        };

        let dest_clone = destinataire.clone();
        let texte_clone = texte_sain.clone();
        let notifs_clone = notifs_actifs.clone(); // Clone de la référence partagée Arc

        // On lance l'activation de la notification en tâche de fond
        tokio::spawn(async move {
            crate::notifications::propulser_notification(
                dest_clone,
                acteur,
                TypeEvenement::Texte,
                texte_clone,
                None, 
                notifs_clone,
            ).await;
        });
    }
}

// mise ajour niveau 2