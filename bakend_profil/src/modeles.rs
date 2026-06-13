use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};
use crate::securite::{assainir_texte, hacher_mot_de_passe};

/// ============================================================================
/// STRUCTURE : Utilisateur
/// ============================================================================
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Utilisateur {
    pub id: String,                 // UUID v4 unique généré côté serveur
    pub email: String,              // Identifiant unique indexé
    pub mot_de_passe_hache: String, // Chiffrement Argon2id ou bcrypt
    pub cree_le: u64,               // Timestamp UNIX (secondes)
    pub profil: Profil,             // Métadonnées du profil public
}

/// ============================================================================
/// STRUCTURE : Profil
/// ============================================================================
#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Profil {
    pub pseudo: String,
    pub nom_utilisateur: String,    // Le handle @unique sans espace ni majuscule
    pub bio: String,
    pub url_avatar: Option<String>,
    pub nb_publications: u64,       // Métriques natives pour opérations atomiques
    pub nb_abonnes: u64,
    pub nb_tribus: u64,
    pub verifie: bool,              // Badge certifié YRION
}

impl Profil {
    /// Assainissement défensif contre les failles XSS, injections de scripts et débordements
    pub fn securiser(&mut self) {
        self.pseudo = assainir_texte(self.pseudo.trim());
        
        // Normalisation radicale du handle @username
        self.nom_utilisateur = assainir_texte(&self.nom_utilisateur)
            .replace(' ', "")
            .replace('@', "")
            .to_lowercase();
            
        // Hard-cap de sécurité sur la taille de la bio pour protéger la RAM contre les attaques DoS
        if self.bio.len() > 160 {
            self.bio = self.bio.chars().take(160).collect();
        }
        self.bio = assainir_texte(self.bio.trim());
    }
}

/// ============================================================================
/// STRUCTURE : BaseDeDonneesGlobale
/// DESCRIPTION : Architecture à indexation distribuée rapide avec vérifications d'intégrité.
/// ============================================================================
#[derive(Serialize, Deserialize, Clone, Debug, Default)]
pub struct BaseDeDonneesGlobale {
    pub utilisateurs: HashMap<String, Utilisateur>, // Clé : Email
    pub index_id: HashMap<String, String>,          // Clé : ID (UUID) -> Valeur : Email
    pub handles_reserves: HashSet<String>,          // Liste d'exclusion rapide O(1) pour les handles
}

/// ============================================================================
/// ENUMERATION : ErreurSysteme
/// DESCRIPTION : Gestion propre et typée des erreurs pour ne jamais exposer la stack de dev.
/// ============================================================================
#[derive(Debug, Serialize)]
pub enum ErreurSysteme {
    EmailDejaUtilise,
    HandleDejaReserve,
    UtilisateurIntrouvable,
    ErreurEcritureDisque,
}

// Implémentation d'affichage pour Axum afin de pouvoir retourner l'erreur en String si nécessaire
impl std::fmt::Display for ErreurSysteme {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ErreurSysteme::EmailDejaUtilise => write!(f, "Cette adresse email est déjà associée à un compte Yrion."),
            ErreurSysteme::HandleDejaReserve => write!(f, "Ce nom d'utilisateur est déjà réservé."),
            ErreurSysteme::UtilisateurIntrouvable => write!(f, "Utilisateur introuvable."),
            ErreurSysteme::ErreurEcritureDisque => write!(f, "Erreur critique d'écriture sur le disque dur."),
        }
    }
}

impl BaseDeDonneesGlobale {
    /// Enregistrement atomique en mémoire avec validation des contraintes d'unicité globales
    pub fn inscrire_utilisateur(&mut self, email: String, password_brut: String, pseudo: String, handle: String) -> Result<Utilisateur, ErreurSysteme> {
        let email_normalise = email.trim().to_lowercase();
        
        let mut profil = Profil {
            pseudo,
            nom_utilisateur: handle,
            bio: String::new(),
            url_avatar: None,
            nb_publications: 0,
            nb_abonnes: 0,
            nb_tribus: 0,
            verifie: false,
        };
        profil.securiser();

        // 1. Barrière anti-doublon d'email
        if self.utilisateurs.contains_key(&email_normalise) {
            return Err(ErreurSysteme::EmailDejaUtilise);
        }

        // 2. Barrière anti-collision de Handle
        if self.handles_reserves.contains(&profil.nom_utilisateur) {
            return Err(ErreurSysteme::HandleDejaReserve);
        }

        // 3. Génération des identifiants sécurisés et horodatage de confiance
        let id_unique = uuid::Uuid::new_v4().to_string();
        let mot_de_passe_hache = hacher_mot_de_passe(&password_brut);
        let maintenant = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();

        let nouvel_utilisateur = Utilisateur {
            id: id_unique.clone(),
            email: email_normalise.clone(),
            mot_de_passe_hache,
            cree_le: maintenant,
            profil,
        };

        // 4. Validation et synchronisation de l'état des index de la base
        self.handles_reserves.insert(nouvel_utilisateur.profil.nom_utilisateur.clone());
        self.index_id.insert(id_unique, email_normalise.clone());
        self.utilisateurs.insert(email_normalise, nouvel_utilisateur.clone());

        Ok(nouvel_utilisateur)
    }
}

/// ============================================================================
/// STRUCTURES DE REQUÊTES (Transit API pour ton controlleur Flutter)
/// ============================================================================
#[derive(Deserialize)]
pub struct RequeteInscription {
    pub email: String,
    pub mot_de_passe: String,
    pub pseudo: String,
    pub nom_utilisateur: String,
}

#[derive(Deserialize)]
pub struct RequeteMiseAJourProfil {
    pub email: String,
    pub pseudo: Option<String>,
    pub nom_utilisateur: Option<String>,
    pub bio: Option<String>,
}

/// ============================================================================
/// COMPOSANT : MoteurDeStockageSecurise
/// DESCRIPTION : Reçoit directement la référence de la BDD à sauvegarder
///               pour correspondre à l'architecture partagée par Axum.
/// ============================================================================
#[derive(Clone)]
pub struct MoteurDeStockageSecurise {
    chemin_stockage: String,
}

impl MoteurDeStockageSecurise {
    pub fn new(chemin: &str) -> Self {
        Self {
            chemin_stockage: chemin.to_string(),
        }
    }

    /// 🔥 SAUVEGARDE ATOMIQUE INTERNATIONALE
    /// Changement : On passe la BDD en paramètre afin d'éviter le conflit de verrous asynchrones.
    pub async fn sauvegarder(&self, bdd: &BaseDeDonneesGlobale) -> Result<(), ErreurSysteme> {
        let donnees_json = serde_json::to_vec_pretty(bdd).map_err(|_| ErreurSysteme::ErreurEcritureDisque)?;
        
        let chemin_temporaire = format!("{}.tmp", self.chemin_stockage);
        
        // 1. Écriture dans le fichier temporaire isolé
        tokio::fs::write(&chemin_temporaire, donnees_json)
            .await
            .map_err(|_| ErreurSysteme::ErreurEcritureDisque)?;
            
        // 2. Remplacement atomique instantané
        tokio::fs::rename(&chemin_temporaire, &self.chemin_stockage)
            .await
            .map_err(|_| ErreurSysteme::ErreurEcritureDisque)?;

        Ok(())
    }
}

// mise a jour 1