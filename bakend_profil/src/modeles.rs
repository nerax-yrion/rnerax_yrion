use serde::{Deserialize, Serialize};
use crate::securite::assainir_texte;

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Profil {
    pub pseudo: String,
    pub nom_utilisateur: String,
    pub bio: String,
    pub url_avatar: Option<String>,
    pub nb_publications: String,
    pub nb_abonnes: String,
    pub nb_tribus: String,
}

impl Profil {
    /// Nettoie et normalise les structures de données en une seule passe efficace
    pub fn securiser(&mut self) {
        self.pseudo = assainir_texte(self.pseudo.trim());
        // Pas d'espaces ni de caractères spéciaux dans le handle @username
        self.nom_utilisateur = assainir_texte(&self.nom_utilisateur)
            .replace(' ', "")
            .to_lowercase();
        self.bio = assainir_texte(self.bio.trim());
    }
}