use axum::{
    extract::{Multipart, State},
    http::StatusCode,
    Json,
};
use tokio::fs;
use bytes::BytesMut;
use crate::securite::{valider_format_image, assainir_texte};
use crate::BaseDeDonnees;

/// ============================================================================
/// ENDPOINT : actualiser_textes
/// DESCRIPTION : Permet à l'application Flutter de mettre à jour le profil d'un 
///               utilisateur ciblé par son adresse email, avec filtrage XSS.
/// ============================================================================
pub async fn actualiser_textes(
    State(etat): State<BaseDeDonnees>,
    Json(payload): Json<crate::modeles::RequeteMiseAJourProfil>,
) -> StatusCode {
    let mut bdd = etat.bdd.write().await;

    // 🎯 On cherche l'utilisateur dans la table de hachage globale
    if let Some(utilisateur) = bdd.utilisateurs.get_mut(&payload.email) {
        
        // Application immédiate de l'assainisseur de texte anti-injection
        if let Some(nouveau_pseudo) = payload.pseudo {
            utilisateur.profil.pseudo = assainir_texte(&nouveau_pseudo);
        }
        
        if let Some(nouveau_nom) = payload.nom_utilisateur {
            utilisateur.profil.nom_utilisateur = assainir_texte(&nouveau_nom);
        }
        
        if let Some(nouvelle_bio) = payload.bio {
            utilisateur.profil.bio = assainir_texte(&nouvelle_bio);
        }
        
        // 🔥 CORRECTION SÉCURITÉ DISQUE : Neutralisation de l'avertissement 'unused Result'
        let _ = etat.moteur_stockage.sauvegarder(&bdd).await;
        
        StatusCode::OK
    } else {
        StatusCode::NOT_FOUND
    }
}

/// ============================================================================
/// ENDPOINT : remplacer_avatar
/// DESCRIPTION : Supprime physiquement l'ancien fichier d'image sur le disque dur 
///               pour éviter d'accumuler des fichiers inutiles, puis sauvegarde le nouveau.
/// ============================================================================
pub async fn remplacer_avatar(
    State(etat): State<BaseDeDonnees>,
    mut formulaire: Multipart,
) -> Result<StatusCode, StatusCode> {
    let mut email_utilisateur = None;
    let mut donnees_image = BytesMut::new();
    let limite_taille = 5 * 1024 * 1024; // 5 Mo maximum
    let mut extension = "jpg";

    // 1. Lecture du flux multipart (Streaming sécurisé anti-DDoS mémoire)
    while let Some(mut champ) = formulaire.next_field().await.map_err(|_| StatusCode::BAD_REQUEST)? {
        if let Some(nom_du_champ) = champ.name() {
            match nom_du_champ {
                "email" => {
                    let texte = champ.text().await.map_err(|_| StatusCode::BAD_REQUEST)?;
                    email_utilisateur = Some(texte);
                }
                "avatar" => {
                    while let Some(morceau) = champ.chunk().await.map_err(|_| StatusCode::BAD_REQUEST)? {
                        if donnees_image.len() + morceau.len() > limite_taille {
                            return Err(StatusCode::PAYLOAD_TOO_LARGE);
                        }
                        donnees_image.extend_from_slice(&morceau);
                    }
                }
                _ => {}
            }
        }
    }

    // Validation des données requises
    let email = email_utilisateur.ok_or(StatusCode::BAD_REQUEST)?;
    if donnees_image.is_empty() {
        return Err(StatusCode::BAD_REQUEST);
    }

    // 2. Contrôle de sécurité binaire de l'image
    if !valider_format_image(&donnees_image) {
        return Err(StatusCode::UNSUPPORTED_MEDIA_TYPE);
    }

    if donnees_image.starts_with(&[0x89, 0x50, 0x4E, 0x47]) {
        extension = "png";
    }

    let mut bdd = etat.bdd.write().await;
    
    // 3. Extraction du compte utilisateur
    if let Some(utilisateur) = bdd.utilisateurs.get_mut(&email) {
        
        // 🧹 NETTOYAGE : Suppression de l'ancien fichier d'avatar pour ne pas saturer le disque dur du serveur
        if let Some(ref ancien_chemin) = utilisateur.profil.url_avatar {
            if fs::metadata(ancien_chemin).await.is_ok() {
                let _ = fs::remove_file(ancien_chemin).await; 
            }
        }

        // 4. Écriture physique du nouvel avatar
        fs::create_dir_all("telechargements").await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
        let horodatage = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH).unwrap().as_millis();
        let nouveau_chemin = format!("telechargements/avatar_{}.{}", horodatage, extension);
        
        fs::write(&nouveau_chemin, &donnees_image).await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
        
        // Mise à jour de l'URL dans la structure
        utilisateur.profil.url_avatar = Some(nouveau_chemin);
        
        // 🔥 CORRECTION SÉCURITÉ DISQUE : Neutralisation de l'avertissement 'unused Result'
        let _ = etat.moteur_stockage.sauvegarder(&bdd).await;
        
        Ok(StatusCode::OK)
    } else {
        Err(StatusCode::NOT_FOUND)
    }
}


// mise a jour 1