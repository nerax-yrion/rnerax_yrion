use crate::protocole::PaquetYrion;
use crate::registre::{envoyer_direct, RegistrePartage};
use crate::securite::valider_texte;

pub async fn gerer_modification(
    id_message: String, expediteur_id: String, destinataire_id: String, nouveau_contenu: String,
    registre: &RegistrePartage, id_verifie: &str
) {
    // 🔐 ANTI-FALSIFICATION : Si un pirate essaie de modifier le message de quelqu'un d'autre
    if expediteur_id != id_verifie {
        println!("🚨 [ALERTE SÉCURITÉ] Tentative de falsification de message par {}", id_verifie);
        return;
    }

    if let Some(texte_sain) = valider_texte(&nouveau_contenu) {
        let paquet = PaquetYrion::ModifierMessage {
            id_message,
            expediteur_id,
            destinataire_id: destinataire_id.clone(),
            nouveau_contenu: texte_sain,
        };
        // Met à jour en direct l'écran de l'autre utilisateur
        envoyer_direct(registre, &destinataire_id, &paquet).await;
    }
}

//mmise ajour 1