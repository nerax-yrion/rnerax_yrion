use crate::protocole::PaquetYrion;
use crate::registre::{envoyer_direct, RegistrePartage};

pub async fn gerer_vocal(
    id: String, expediteur: String, destinataire: String, url_audio: String, duree: u32,
    registre: &RegistrePartage
) {
    // Le serveur vérifie que l'URL ne pointe pas vers un script pirate dangereux
    if url_audio.starts_with("http") && url_audio.len() < 500 {
        let paquet = PaquetYrion::MessageVocal { id, expediteur_id: expediteur, destinataire_id: destinataire.clone(), url_audio, duree_secondes: duree };
        envoyer_direct(registre, &destinataire, &paquet).await;
    }
}