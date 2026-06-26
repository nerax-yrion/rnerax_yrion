use crate::protocole::{PaquetRecherche, ProfilPublic};
use crate::securite::assainir_saisie_recherche;
use axum::extract::ws::Message;
use tokio::sync::mpsc;
use sqlx::PgPool;

// Structure temporaire nécessaire à SQLx pour mapper les données sans vérification "offline"
#[derive(sqlx::FromRow)]
struct RowUtilisateur {
    user_id: String,
}

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
        // La logique exacte et le tri par similarité restent à 100% identiques
        let requete_db = sqlx::query_as::<_, RowUtilisateur>(
            r#"
            SELECT user_id
            FROM user_profiles 
            WHERE lower(unaccent(pseudo)) % lower(unaccent($1)) 
               OR lower(username) % lower($1)
               OR lower(unaccent(pseudo)) LIKE lower(unaccent($2))
            ORDER BY greatest(
                similarity(lower(unaccent(pseudo)), lower(unaccent($1))), 
                similarity(lower(username), lower($1))
            ) DESC
            LIMIT 10
            "#
        )
        .bind(recherche_propre)
        .bind(format!("%{}%", recherche_propre))
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