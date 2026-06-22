use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "action", content = "donnees")]
pub enum PaquetYrion {
    EnregistrerAstronaute { user_id: String },

    // 💬 MICRO-MOTEURS MESSAGERIE
    MessageTexte { id: String, expediteur_id: String, destinataire_id: String, contenu: String },
    ModifierMessage { id_message: String, expediteur_id: String, destinataire_id: String, nouveau_contenu: String },
    MessageVocal { id: String, expediteur_id: String, destinataire_id: String, url_audio: String, duree_secondes: u32 },

    // 📞 MICRO-MOTEURS APPELS
    AppelNormal { emetteur_id: String, recepteur_id: String, etape: String, sdp: Option<String> },
    AppelVideo { emetteur_id: String, recepteur_id: String, etape: String, sdp: Option<String> },

    // 🛡️ SÉCURITÉ ET ÉTATS
    ChangementStatut { message_id: String, etat: String },
    AlerteSecurite { message: String },
}

//mmise ajour 1