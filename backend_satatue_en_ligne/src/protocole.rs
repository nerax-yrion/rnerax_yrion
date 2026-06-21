use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "action", content = "donnees")]
pub enum PaquetPresence {
    // Demande d'enregistrement d'un astronaute
    EnregistrerAstronaute { user_id: String },
    
    // Alerte envoyée à toute la galaxie
    MiseAJourStatut { user_id: String, en_ligne: bool },
}