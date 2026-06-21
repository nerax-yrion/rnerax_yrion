use std::collections::{HashMap, HashSet};
use axum::extract::ws::Message;
use tokio::sync::{mpsc, RwLock};
use std::sync::Arc;
use crate::protocole::PaquetPresence;

pub struct PlanetePresence {
    pub utilisateurs_actifs: HashSet<String>,
    pub sessions: HashMap<String, mpsc::UnboundedSender<Message>>,
}

pub type RegistrePartage = Arc<RwLock<PlanetePresence>>;

impl PlanetePresence {
    pub fn initialiser(capacite_depart: usize) -> Self {
        Self {
            utilisateurs_actifs: HashSet::with_capacity(capacite_depart),
            sessions: HashMap::with_capacity(capacite_depart),
        }
    }
}

pub fn diffuser_statut_galaxie(planete: &PlanetePresence, user_id: String, en_ligne: bool) {
    let structure_message = PaquetPresence::MiseAJourStatut {
        user_id: user_id.clone(),
        en_ligne,
    };

    if let Ok(texte_json) = serde_json::to_string(&structure_message) {
        let message_ws = Message::Text(texte_json);

        for (id_session, canal_transmission) in &planete.sessions {
            if id_session != &user_id {
                let _ = canal_transmission.send(message_ws.clone());
            }
        }
    }
}