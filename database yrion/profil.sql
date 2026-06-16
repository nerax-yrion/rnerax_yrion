-- ====================================================================
-- MODULE      : GESTION DES PROFILS UTILISATEURS (YRION ARCHITECTURE)
-- COMPOSANT   : COMPTEUR & SÉCURITÉ DES CAPTEURS D'IDENTITÉ
-- COMPATIBILITÉ : Rust 100% (Axum, Multipart, XSS) & Flutter (ProfilData)
-- ====================================================================

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS user_profiles (
    -- Liaison immuable et stricte avec l'authentification centrale
    user_id TEXT PRIMARY KEY NOT NULL UNIQUE,
    
    -- Pseudo d'affichage nettoyé avec interdiction des espaces invisibles isolés
    pseudo TEXT NOT NULL CHECK(length(trim(pseudo)) >= 1 AND pseudo = trim(pseudo)),
    
    -- Nom d'utilisateur unique (sans majuscules pour éviter les doublons trompeurs 'Alex' vs 'alex')
    username TEXT NOT NULL UNIQUE CHECK(
        length(trim(username)) >= 3 
        AND username = lower(trim(username)) 
        AND username NOT LIKE '% %'
    ),
    
    -- Biographie assainie (Limitée à 500 caractères pour éviter les saturations de payload HTTP)
    bio TEXT DEFAULT '' CHECK(length(bio) <= 500),
    
    -- Localisation de l'avatar physique (validation stricte des formats autorisés par Rust)
    profile_image_path TEXT DEFAULT NULL CHECK(
        profile_image_path IS NULL OR 
        profile_image_path LIKE 'telechargements/%.png' OR 
        profile_image_path LIKE 'telechargements/%.jpg' OR 
        profile_image_path LIKE 'telechargements/%.jpeg'
    ),
    
    -- Métriques verrouillées (Type INTEGER natif)
    nb_publications INTEGER DEFAULT 0 NOT NULL CHECK(nb_publications >= 0),
    nb_abonnes INTEGER DEFAULT 0 NOT NULL CHECK(nb_abonnes >= 0),
    nb_abonnements INTEGER DEFAULT 0 NOT NULL CHECK(nb_abonnements >= 0),
    
    -- Horodatages automatisés
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ====================================================================
-- COUCHE DE SÉCURITÉ AUTOMATIQUE (TRIGGERS / DÉCLENCHEURS)
-- ====================================================================

-- Déclencheur 1 : Force la mise à jour automatique de la colonne 'updated_at' à chaque modification
CREATE TRIGGER IF NOT EXISTS trg_user_profiles_update_timestamp
AFTER UPDATE ON user_profiles
FOR EACH ROW
BEGIN
    UPDATE user_profiles 
    SET updated_at = CURRENT_TIMESTAMP 
    WHERE user_id = OLD.user_id;
END;

-- Déclencheur 2 : Sécurité anti-fraude sur l'historique de création
CREATE TRIGGER IF NOT EXISTS trg_user_profiles_protect_history
BEFORE UPDATE OF created_at ON user_profiles
FOR EACH ROW
BEGIN
    SELECT RAISE(FAIL, 'INTERDICTION : La date de création du profil est immuable dans l''écosystème Yrion.');
END;

-- ====================================================================
-- INDEX DE PERFORMANCE CRITIQUES
-- ====================================================================

-- Index de recherche unique : accélère instantanément les vérifications de disponibilité de l'arborescence
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_username_perf ON user_profiles(username);

-- Index composite : Optimise les jointures et l'agrégation des statistiques globales
CREATE INDEX IF NOT EXISTS idx_profiles_stats_composite ON user_profiles(user_id, nb_publications, nb_abonnes);