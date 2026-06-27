use crate::protocole::{PaquetRecherche, ProfilPublic};
use crate::securite::assainir_saisie_recherche;
use axum::extract::ws::Message;
use tokio::sync::mpsc;
use sqlx::PgPool;

// Structure temporaire adaptée pour décoder nativement les UUID de PostgreSQL
#[derive(sqlx::FromRow)]
struct RowUtilisateur {
    user_id: sqlx::types::Uuid, // 👈 Mappe l'UUID PostgreSQL directement
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
        // Utilisation obligatoire du wrapper immuable pour mordre sur l'index GIN_v4
        let requete_db = sqlx::query_as::<_, RowUtilisateur>(
            r#"
            SELECT user_id
            FROM user_profiles 
            WHERE lower(public.yrion_unaccent_immutable(pseudo)) % lower(public.yrion_unaccent_immutable($1)) 
               OR lower(username) % lower($1)
               OR lower(public.yrion_unaccent_immutable(pseudo)) LIKE lower(public.yrion_unaccent_immutable($2))
            ORDER BY greatest(
                similarity(lower(public.yrion_unaccent_immutable(pseudo)), lower(public.yrion_unaccent_immutable($1))), 
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
                        // On convertit l'UUID en String pour ton client Flutter
                        user_id: ligne.user_id.to_string(), 
                        en_ligne: true, // Géré dynamiquement par l'écosystème Yrion
                    });
                }

                // Envoi instantané du paquet JSON converti au client Flutter
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