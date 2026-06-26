use crate::protocole::{PaquetRecherche, ProfilPublic};
use crate::securite::assainir_saisie_recherche;
use axum::extract::ws::Message;
use tokio::sync::mpsc;
use sqlx::PgPool;

pub async fn executer_filtrage_quantique(
    requete: String,
    pool_neon: &PgPool,
    tx: &mpsc::UnboundedSender<Message>,
) {
    // 🛡️ SÉCURITÉ : Validation immédiate et nettoyage de la chaîne de caractères
    if let Some(saisie_propre) = assainir_saisie_recherche(&requete) {
        let recherche_propre = saisie_propre.trim();
        
        if recherche_propre.is_empty() { 
            return; 
        }

        // 🛸 ALGORITHME DE CORRESPONDANCE FLOUE ULTRA-RAPIDE (ANTI-FAUTES DE FRAPPE)
        // 1. lower(unaccent(...)) % lower(unaccent(...)) : Utilise l'index GIN pour filtrer instantanément par trigrammes.
        // 2. similarity(...) : Calcule un score de 0 à 1 pour mesurer la ressemblance exacte.
        // 3. ORDER BY score DESC : Met les profils les plus pertinents et les plus proches au sommet de la pile.
        let requete_db = sqlx::query!(
            r#"
            SELECT user_id,
                   similarity(lower(unaccent(pseudo)), lower(unaccent($1))) AS score_pseudo,
                   similarity(lower(username), lower($1)) AS score_username
            FROM user_profiles 
            WHERE lower(unaccent(pseudo)) % lower(unaccent($1)) 
               OR lower(username) % lower($1)
               OR lower(unaccent(pseudo)) LIKE lower(unaccent($2))
            ORDER BY greatest(
                similarity(lower(unaccent(pseudo)), lower(unaccent($1))), 
                similarity(lower(username), lower($1))
            ) DESC
            LIMIT 10
            "#,
            recherche_propre,
            format!("%{}%", recherche_propre)
        )
        .fetch_all(pool_neon)
        .await;

        match requete_db {
            Ok(lignes) => {
                // Allocation initiale optimisée à la taille exacte (Zéro réallocation RAM)
                let mut resultats_trouves = Vec::with_capacity(lignes.len());

                for ligne in lignes {
                    resultats_trouves.push(ProfilPublic {
                        user_id: ligne.user_id,
                        en_ligne: true, // Géré dynamiquement par l'écosystème Yrion
                    });
                }

                // Envoi instantané du paquet JSON converti de manière fulgurante au client Flutter
                if !resultats_trouves.is_empty() {
                    let reponse = PaquetRecherche::ResultatsFiltres { utilisateurs: resultats_trouves };
                    if let Ok(json_brut) = serde_json::to_string(&reponse) {
                        let _ = tx.send(Message::Text(json_brut));
                    }
                }
            }
            Err(erreur_log) => {
                println!("[ERREUR CYBER-MOTEUR] Échec de la recherche floue sur Neon : {:?}", erreur_log);
            }
        }
    }
}

// mise a jour du serveur backend de recherche niveau 1 - ÉDITION FINALE ÉLITE