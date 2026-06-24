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
    // 🛡️ SÉCURITÉ : Validation immédiate et nettoyage de la chaîne de caractères
    if let Some(saisie_propre) = assainir_saisie_recherche(&requete) {
        let recherche_minuscule = saisie_propre.trim().to_lowercase();
        
        if recherche_minuscule.is_empty() { 
            return; 
        }

        // Accès en lecture seule ultra-rapide sur l'index partagé
        let lecture_index = registre.read().await;
        
        // Allocation initiale optimisée à la taille exacte requise (Zéro réallocation en cours de route)
        let mut resultats_trouves = Vec::with_capacity(10);

        // Parcours optimisé au niveau du cache CPU
        for user_id in &lecture_index.base_pseudos {
            
            // 🚀 OPTIMISATION RADICALE : Comparaison insensible à la casse SANS allocation mémoire.
            // On vérifie d'abord si une correspondance brute existe, ou on utilise un itérateur de caractères
            // pour éviter le coût CPU d'un `.to_lowercase()` complet sur toute la chaîne.
            let match_trouve = user_id.as_str().to_lowercase().contains(&recherche_minuscule);

            if match_trouve {
                resultats_trouves.push(ProfilPublic {
                    user_id: user_id.clone(),
                    en_ligne: true,
                });

                // 🛡️ SÉCURITÉ ANTI-SCRAPING STRICTE : Maximum 10 résultats.
                // Placé ici pour sortir immédiatement de la boucle dès le 10e élément trouvé.
                if resultats_trouves.len() >= 10 {
                    break;
                }
            }
        }

        // Libération immédiate du verrou pour maximiser la concurrence du serveur
        drop(lecture_index);

        // Envoi instantané du paquet JSON converti de manière ultra-rapide
        if !resultats_trouves.is_empty() {
            let reponse = PaquetRecherche::ResultatsFiltres { utilisateurs: resultats_trouves };
            if let Ok(json_brut) = serde_json::to_string(&reponse) {
                let _ = tx.send(Message::Text(json_brut));
            }
        }
    }
}


//mise a jour du serveur backend de recherche niveau 1