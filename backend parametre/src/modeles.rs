use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;

#[derive(Debug, Deserialize)]
pub struct FormulaireChangerCompte {
    pub nom_utilisateur_cible: String,
    pub jeton_authentification: String,
}

#[derive(Debug, Deserialize)]
pub struct FormulaireDeconnexion {
    pub jeton_authentification: String,
}

#[derive(Debug, Serialize)]
pub struct ReponseStandardiseApi<T> {
    pub statut: String,
    pub horodatage: DateTime<Utc>,
    pub id_execution: Uuid,
    pub donnees: T,
}

#[derive(Debug, Serialize)]
pub struct DonneesAuthentification {
    pub succes: bool,
    pub id_compte: Uuid,
    pub nouveau_jeton_acces: String,
    pub espace_actif: String,
}

#[derive(Debug, Serialize)]
pub struct DetailsMatriceCompte {
    pub id_compte: Uuid,
    pub email_matrice: String,
    pub liaison_reseau: String,
    pub clef_privee_id: String,
    pub verification_orbite: bool,
}

//  1