use crate::protocole::PaquetYrion;
use crate::registre::{envoyer_direct, RegistrePartage};

pub async fn gerer_appel_audio(
    emetteur: String, recepteur: String, etape: String, sdp: Option<String>,
    registre: &RegistrePartage
) {
    let paquet = PaquetYrion::AppelNormal { emetteur_id: emetteur, recepteur_id: recepteur.clone(), etape, sdp };
    envoyer_direct(registre, &recepteur, &paquet).await;
}