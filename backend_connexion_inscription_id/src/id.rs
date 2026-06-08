use uuid::Uuid;

/// Génère un UUID v4 natif basé sur un générateur de nombres aléatoires matériel ultra-sécurisé.
pub fn generer_id_unique() -> Uuid {
    Uuid::new_v4()
}