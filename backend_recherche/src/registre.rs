use std::collections::HashSet;
use tokio::sync::RwLock;
use std::sync::Arc;

pub struct CatalogueUtilisateurs {
    // Indexation à mémoire fixe pour une recherche en temps constant
    pub base_pseudos: HashSet<String>,
}

pub type RegistrePartage = Arc<RwLock<CatalogueUtilisateurs>>;

impl CatalogueUtilisateurs {
    pub fn initialiser_haute_capacite(taille_allocation: usize) -> Self {
        Self {
            base_pseudos: HashSet::with_capacity(taille_allocation),
        }
    }
}