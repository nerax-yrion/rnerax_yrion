use crate::protocole::PaquetYrion;
use crate::registre::{envoyer_direct, RegistrePartage};
use crate::securite::valider_texte;
use axum::extract::ws::Message;
use tokio::sync::mpsc;

pub async fn gerer_texte(
    id: String, expediteur: String, destinataire: String, contenu: String,
    registre: &RegistrePartage, tx: &mpsc::UnboundedSender<Message>
) {
    if let Some(texte_sain) = valider_texte(&contenu) {
        let paquet = PaquetYrion::MessageTexte {
            id: id.clone(), expediteur_id: expediteur, destinataire_id: destinataire.clone(), contenu: texte_sain,
        };
        
        let livre = envoyer_direct(registre, &destinataire, &paquet).await;
        let confirmation = PaquetYrion::ChangementStatut {
            message_id: id,
            etat: if livre { "recu".to_string() } else { "envoye".to_string() },
        };
        let _ = tx.send(Message::Text(serde_json::to_string(&confirmation).unwrap()));
    }
}