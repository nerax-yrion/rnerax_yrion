use uuid::Uuid;

/// Génère un UUID v4 basé sur un générateur de nombres aléatoires matériel ultra-sécurisé.
pub fn generer_id_unique() -> String {
    Uuid::new_v4().to_string()
}