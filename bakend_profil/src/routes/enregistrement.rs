use axum::{
    extract::{Multipart, State},
    http::StatusCode,
};
use tokio::fs;
use crate::securite::valider_format_image;
use crate::BaseDeDonnees;

pub async fn ajouter_avatar(
    State(etat): State<BaseDeDonnees>,
    mut formulaire: Multipart,
) -> Result<StatusCode, StatusCode> {
    while let Some(champ) = formulaire.next_field().await.map_err(|_| StatusCode::BAD_REQUEST)? {
        if champ.name() == Some("avatar") {
            let donnees = champ.bytes().await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
            
            // 🚨 Validation binaire instantanée
            if !valider_format_image(&donnees) {
                return Err(StatusCode::UNSUPPORTED_MEDIA_TYPE);
            }

            // Limite stricte : 5 Mo
            if donnees.len() > 5 * 1024 * 1024 {
                return Err(StatusCode::PAYLOAD_TOO_LARGE);
            }
            
            // I/O asynchrone non-bloquante avec Tokio
            fs::create_dir_all("telechargements").await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
            
            let horodatage = std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH).unwrap().as_millis();
            let chemin_fichier = format!("telechargements/avatar_{}.jpg", horodatage);
            
            fs::write(&chemin_fichier, donnees).await.map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
            
            // Écriture asynchrone sécurisée dans la mémoire globale
            let mut profil = etat.bdd.write().await;
            profil.url_avatar = Some(chemin_fichier.clone());
            
            // 🔥 SAUVEGARDE PERMANENTE SUR LE DISQUE :
            // Le serveur écrit les nouvelles données dans le JSON pour qu'elles survivent aux redémarrages.
            crate::sauvegarder_profil(&profil).await;
            
            return Ok(StatusCode::CREATED);
        }
    }
    Err(StatusCode::BAD_REQUEST)
}
// mise jour 