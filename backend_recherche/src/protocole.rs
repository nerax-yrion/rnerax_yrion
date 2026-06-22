use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ProfilPublic {
    pub user_id: String,
    pub en_ligne: bool,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
#[serde(tag = "action", content = "donnees")]
pub enum PaquetRecherche {
    // Permet d'alimenter la base de données en RAM (venant de ton serveur de messages)
    AlimenterCatalogue { user_id: String },
    
    // Requête émise par l'application Flutter lors de la saisie
    LancerRecherche { requete: String },
    
    // Réponse ultra-rapide renvoyée à l'utilisateur
    ResultatsFiltres { utilisateurs: Vec<ProfilPublic> },
}