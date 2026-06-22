use std::collections::{HashMap, HashSet};
use axum::extract::ws::Message;
use tokio::sync::{mpsc, RwLock};
use std::sync::Arc;
use crate::protocole::PaquetYrion;

pub struct StationCentrale {
    pub astronautes_actifs: HashSet<String>,
    pub terminaux: HashMap<String, mpsc::UnboundedSender<Message>>,
}

pub type RegistrePartage = Arc<RwLock<StationCentrale>>;

impl StationCentrale {
    pub fn initialiser(capacite: usize) -> Self {
        Self {
            astronautes_actifs: HashSet::with_capacity(capacite),
            terminaux: HashMap::with_capacity(capacite),
        }
    }
}

pub async fn envoyer_direct(registre: &RegistrePartage, cible_id: &str, paquet: &PaquetYrion) -> bool {
    if let Ok(json) = serde_json::to_string(paquet) {
        let lecture = registre.read().await;
        if let Some(canal) = lecture.terminaux.get(cible_id) {
            return canal.send(Message::Text(json)).is_ok();
        }
    }
    false
}

//mmise ajour 1