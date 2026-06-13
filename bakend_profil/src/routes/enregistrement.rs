use axum::{
    extract::{Multipart, State},
    http::StatusCode,
};
use tokio::fs;
use bytes::BytesMut;
use crate::securite::valider_format_image;
use crate::BaseDeDonnees;

/// ============================================================================
/// ENDPOINT : inscrire_nouvel_utilisateur
/// DESCRIPTION : Reçoit les requêtes JSON d'inscription de ton application Flutter
/// ============================================================================
pub async fn inscrire_nouvel_utilisateur(
    State(etat): State<BaseDeDonnees>,
    axum::Json(payload): axum::Json<crate::modeles::RequeteInscription>,
) -> Result<StatusCode, (StatusCode, String)> {
    let mut bdd = etat.bdd.write().await;
    
    // Tentative d'inscription atomique via notre modèle sécurisé
    match bdd.inscrire_utilisateur(
        payload.email,
        payload.mot_de_passe,
        payload.pseudo,
        payload.nom_utilisateur,
    ) {
        Ok(_) => {
            // Sauvegarde immédiate sur le disque dur via l'écriture atomique d'Yrion
            if let Err(_) = etat.moteur_stockage.sauvegarder(&bdd).await {
                return Err((StatusCode::INTERNAL_SERVER_ERROR, "Erreur d'écriture disque".to_string()));
            }
            Ok(StatusCode::CREATED) 
        }
        Err(erreur) => Err((StatusCode::BAD_REQUEST, erreur.to_string())),
    }
}

/// ============================================================================
/// ENDPOINT : ajouter_avatar
/// DESCRIPTION : Traite le flux multipart d'une image avec protection RAM
/// ============================================================================
pub async fn ajouter_avatar(
    State(etat): State<BaseDeDonnees>,
    mut formulaire: Multipart,
) -> Result<StatusCode, StatusCode> {
    let mut email_utilisateur = None;
    let mut donnees_image = BytesMut::new();
    let limite_taille = 5 * 1024 * 1024; // 5 Mo maximum
    let mut extension = "jpg";

    // 1. Extraction et streaming sécurisé du formulaire multipart
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

    let email = email_utilisateur.ok_or(StatusCode::BAD_REQUEST)?;
    if donnees_image.is_empty() {
        return Err(StatusCode::BAD_REQUEST);
    }

    // 2. Validation cryptographique
    if !valider_format_image(&donnees_image) {
        return Err(StatusCode::UNSUPPORTED_MEDIA_TYPE);
    }

    if donnees_image.starts_with(&[0x89, 0x50, 0x4E, 0x47]) {
        extension = "png";
    }

    // 3. Écriture asynchrone sur le disque dur
    fs::create_dir_all("telechargements").await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    let horodatage = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH).unwrap().as_millis();
    let chemin_fichier = format!("telechargements/avatar_{}.{}", horodatage, extension);
    
    fs::write(&chemin_fichier, &donnees_image).await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    // 4. Enregistrement dans la HashMap globale de l'utilisateur cible
    let mut bdd = etat.bdd.write().await;
    if let Some(utilisateur) = bdd.utilisateurs.get_mut(&email) {
        utilisateur.profil.url_avatar = Some(chemin_fichier);
        
        let _ = etat.moteur_stockage.sauvegarder(&bdd).await;
        Ok(StatusCode::OK)
    } else {
        Err(StatusCode::NOT_FOUND)
    }
}

// mise a jour 1