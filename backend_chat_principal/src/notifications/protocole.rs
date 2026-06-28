// src/notifications/protocole.rs
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum TypeEvenement {
    Texte,
    Vocal,
    AppelNormal,
    AppelVideo,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub enum PhaseParcours {
    Initialisation, // Signal créé
    Encoding,       // Chiffrement Yrion Core terminé
    Dispatch,       // Routage prioritaire RAM effectué
    Livraison,      // Arrivée de l'OVNI sur le device
    Activation,     // Ouverture de la bulle et affichage
}

#[derive(Debug, Serialize, Deserialize, Clone, Copy, PartialEq)]
pub enum ModeRoutage {
    SuperSonique, // Zéro latence (pour les appels)
    Standard,     // Flux cadencé (pour les messages/vocaux)
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ActeurNotif {
    pub user_id: String,
    pub username: String,
    pub profile_image_url: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct PaquetNotificationQuantique {
    pub notification_id: String,
    pub type_evenement: TypeEvenement,
    pub phase: PhaseParcours,
    pub mode: ModeRoutage,
    pub acteur: ActeurNotif,
    pub message_apercu: String,
    pub bouton_action: Option<String>,
    pub cible_id: Option<String>,
    pub horodatage_ns: u128, // Précision nanoseconde pour le calibrage de latence
}

// mise a jour niveau 1