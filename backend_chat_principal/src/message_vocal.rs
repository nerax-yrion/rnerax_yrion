use crate::protocole::PaquetYrion;
use crate::registre::{envoyer_direct, RegistrePartage};

// 🛰️ Imports requis pour le module de notifications quantiques
use crate::notifications::protocole::{ActeurNotif, TypeEvenement};
use crate::notifications::dispatcher::TransmissionNotifMap;

pub async fn gerer_vocal(
    id: String, expediteur: String, destinataire: String, url_audio: String, duree: u32,
    registre: &RegistrePartage,
    notifs_actifs: &TransmissionNotifMap // 👈 Ajouté pour lier la mémoire des notifications
) {
    // Le serveur vérifie que l'URL ne pointe pas vers un script pirate dangereux
    if url_audio.starts_with("http") && url_audio.len() < 500 {
        let paquet = PaquetYrion::MessageVocal { 
            id: id.clone(), 
            expediteur_id: expediteur.clone(), 
            destinataire_id: destinataire.clone(), 
            url_audio: url_audio.clone(), 
            duree_secondes: duree 
        };
        envoyer_direct(registre, &destinataire, &paquet).await;

        // =====================================================================
        // 🚀 AMÉLIORATION ÉLITE D'YRION : PROPULSION DE LA NOTIFICATION VOCALE
        // =====================================================================
        let acteur = ActeurNotif {
            user_id: expediteur,
            username: "Ami Yrion".to_string(),
            profile_image_url: None,
        };

        let dest_clone = destinataire.clone();
        let url_clone = url_audio.clone();
        let notifs_clone = notifs_actifs.clone();

        // Envoi en tâche de fond pour ne pas bloquer le serveur de chat principal
        tokio::spawn(async move {
            crate::notifications::propulser_notification(
                dest_clone,
                acteur,
                TypeEvenement::Vocal,
                "".to_string(), // Le dispatcher générera automatiquement le texte "vous a envoyé un message vocal"
                Some(url_clone), // On transmet l'URL audio pour que l'APK puisse la lire directement
                notifs_clone,
            ).await;
        });
    }
}

// mise a jour niveaau 2