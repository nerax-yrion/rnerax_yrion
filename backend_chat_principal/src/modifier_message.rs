use crate::protocole::PaquetYrion;
use crate::registre::{envoyer_direct, RegistrePartage};
use crate::securite::valider_texte;

// 🛰️ Imports requis pour le module de notifications quantiques et la RAM
use crate::notifications::protocole::{ActeurNotif, TypeEvenement};
use crate::notifications::dispatcher::TransmissionNotifMap;

pub async fn gerer_modification(
    id_message: String, expediteur_id: String, destinataire_id: String, nouveau_contenu: String,
    registre: &RegistrePartage, 
    id_verifie: &str,
    notifs_actifs: &TransmissionNotifMap // 👈 Connecté à la RAM
) {
    // 🔐 ANTI-FALSIFICATION : Si un pirate essaie de modifier le message de quelqu'un d'autre
    if expediteur_id != id_verifie {
        println!("🚨 [ALERTE SÉCURITÉ] Tentative de falsification de message par {}", id_verifie);
        return;
    }

    if let Some(texte_sain) = valider_texte(&nouveau_contenu) {
        let paquet = PaquetYrion::ModifierMessage {
            id_message: id_message.clone(),
            expediteur_id: expediteur_id.clone(),
            destinataire_id: destinataire_id.clone(), // 🛠️ CORRIGÉ : Plus de faute de frappe ici !
            nouveau_contenu: texte_sain.clone(),
        };
        // Met à jour en direct l'écran de l'autre utilisateur (Chat classique)
        envoyer_direct(registre, &destinataire_id, &paquet).await;

        // =====================================================================
        // 🚀 AMÉLIORATION ÉLITE D'YRION : MISE À JOUR DE LA NOTIFICATION FLUTTER
        // =====================================================================
        let acteur = ActeurNotif {
            user_id: expediteur_id,
            username: "Ami Yrion".to_string(),
            profile_image_url: None,
        };

        let dest_clone = destinataire_id.clone();
        let texte_clone = texte_sain.clone();
        let notifs_clone = notifs_actifs.clone();
        let msg_id_clone = id_message.clone();

        // On balance la mise à jour réseau en tâche de fond (asynchrone)
        tokio::spawn(async move {
            crate::notifications::propulser_notification(
                dest_clone,
                acteur,
                TypeEvenement::Texte, 
                format!("(Modifié) : {}", texte_clone), 
                Some(msg_id_clone), // Passe l'ID pour remplacer la bonne notification sur l'APK
                notifs_clone,
            ).await;
        });
    }
}

// mise a jour niveau 2