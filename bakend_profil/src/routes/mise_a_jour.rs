use axum::{
    extract::{Multipart, State},
    http::StatusCode,
    Json,
};
use tokio::fs;
use crate::modeles::Profil;
use crate::securite::valider_format_image;
use crate::BaseDeDonnees;

pub async fn actualiser_textes(
    State(etat): State<BaseDeDonnees>,
    Json(mut nouvelles_infos): Json<Profil>,
) -> StatusCode {
    nouvelles_infos.securiser();

    let mut profil = etat.bdd.write().await;
    profil.pseudo = nouvelles_infos.pseudo;
    profil.nom_utilisateur = nouvelles_infos.nom_utilisateur;
    profil.bio = nouvelles_infos.bio;
    
    // 🔥 SAUVEGARDE PERMANENTE SUR LE DISQUE :
    // On enregistre les nouveaux textes dans le JSON
    crate::sauvegarder_profil(&profil).await;
    
    StatusCode::OK
}

pub async fn remplacer_avatar(
    State(etat): State<BaseDeDonnees>,
    mut formulaire: Multipart,
) -> Result<StatusCode, StatusCode> {
    while let Some(champ) = formulaire.next_field().await.map_err(|_| StatusCode::BAD_REQUEST)? {
        if champ.name() == Some("avatar") {
            let donnees = champ.bytes().await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
            
            if !valider_format_image(&donnees) || donnees.len() > 5 * 1024 * 1024 {
                return Err(StatusCode::BAD_REQUEST);
            }
            
            let mut profil = etat.bdd.write().await;
            
            // Suppression asynchrone sécurisée de l'ancien fichier
            if let Some(ref ancien_chemin) = profil.url_avatar {
                if ancien_chemin.starts_with("telechargements/") {
                    let _ = fs::remove_file(ancien_chemin).await;
                }
            }

            let horodatage = std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH).unwrap().as_millis();
            let nouveau_chemin = format!("telechargements/avatar_{}.jpg", horodatage);
            
            fs::write(&nouveau_chemin, donnees).await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
            profil.url_avatar = Some(nouveau_chemin);
            
            // 🔥 SAUVEGARDE PERMANENTE SUR LE DISQUE :
            // On enregistre le nouveau chemin de l'image pour qu'il soit rechargé au démarrage
            crate::sauvegarder_profil(&profil).await;
            
            return Ok(StatusCode::OK);
        }
    }
    Err(StatusCode::BAD_REQUEST)
}

//mise a jour 