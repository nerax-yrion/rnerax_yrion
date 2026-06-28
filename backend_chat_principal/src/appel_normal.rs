use crate::protocole::PaquetYrion;
use crate::registre::{envoyer_direct, RegistrePartage};

// 🛰️ Imports requis pour le module de notifications quantiques
use crate::notifications::protocole::{ActeurNotif, TypeEvenement};
use crate::notifications::dispatcher::TransmissionNotifMap;

pub async fn gerer_appel_audio(
    emetteur: String, recepteur: String, etape: String, sdp: Option<String>,
    registre: &RegistrePartage,
    notifs_actifs: &TransmissionNotifMap // 👈 Ajouté pour connecter la RAM de notifications
) {
    let paquet = PaquetYrion::AppelNormal { 
        emetteur_id: emetteur.clone(), 
        recepteur_id: recepteur.clone(), 
        etape: etape.clone(), 
        sdp 
    };
    envoyer_direct(registre, &recepteur, &paquet).await;

    // =====================================================================
    // 🚀 AMÉLIORATION ÉLITE D'YRION : NOTIFICATION D'APPEL EN DIRECT
    // =====================================================================
    // On déclenche l'animation de l'OVNI uniquement quand l'appel commence à sonner ("offre")
    if etape == "offre" {
        let acteur = ActeurNotif {
            user_id: emetteur,
            username: "Astronaute Yrion".to_string(),
            profile_image_url: None,
        };

        let dest_clone = recepteur.clone();
        let notifs_clone = notifs_actifs.clone();

        // Propulsion instantanée en tâche de fond
        tokio::spawn(async move {
            crate::notifications::propulser_notification(
                dest_clone,
                acteur,
                TypeEvenement::AppelNormal,
                "".to_string(), // Le dispatcher se charge de formater le texte d'appel audio
                None, // Pas besoin d'URL ici, l'APK Flutter utilise le paquet WebRTC
                notifs_clone,
            ).await;
        });
    }
}

// mise ajour niveau 2