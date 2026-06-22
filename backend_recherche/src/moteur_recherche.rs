use crate::protocole::{PaquetRecherche, ProfilPublic};
use crate::registre::RegistrePartage;
use crate::securite::assainir_saisie_recherche;
use axum::extract::ws::Message;
use tokio::sync::mpsc;

pub async fn executer_filtrage_quantique(
    requete: String,
    registre: &RegistrePartage,
    tx: &mpsc::UnboundedSender<Message>,
) {
    // 🛡️ SÉCURITÉ : Validation immédiate de la chaîne de caractères
    if let Some(saisie_propre) = assainir_saisie_recherche(&requete) {
        let recherche_minuscule = saisie_propre.to_lowercase().trim().to_string();
        
        let lecture_index = registre.read().await;
        let mut resultats_trouves = Vec::new();

        if recherche_minuscule.is_empty() { return; }

        // Parcours asynchrone en mémoire vive (RAM) à la vitesse de l'éclair
        for user_id in &lecture_index.base_pseudos {
            if user_id.to_lowercase().contains(&recherche_recherche_minuscule) {
                resultats_trouves.push(ProfilPublic {
                    user_id: user_id.clone(),
                    en_ligne: true,
                });
            }

            // 🛡️ SÉCURITÉ ANTI-SCRAPING STRICTE : Maximum 10 résultats renvoyés par lettre tapée.
            // Cela empêche un utilisateur malveillant de récupérer l'ensemble de tes membres.
            if resultats_trouves.len() >= 10 {
                break;
            }
        }

        // Envoi instantané du paquet JSON au format binaire à travers la socket
        let reponse = PaquetRecherche::ResultatsFiltres { utilisateurs: resultats_trouves };
        if let Ok(json_brut) = serde_json::to_string(&reponse) {
            let _ = tx.send(Message::Text(json_brut));
        }
    }
}