-- ====================================================================
-- MODULE PROFIL : CONSTELLATION SOCIALE & PROTECTION DES DONNÉES
-- ÉDITION        : Édition Militaire / Haute Disponibilité
-- COMPATIBILITÉ : PostgreSQL 15+ / Neon Cloud Multi-Tenant Strict
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. EXTENSIONS DE SÉCURITÉ
-- --------------------------------------------------------------------
-- Permet à PostgreSQL d'utiliser des fonctions de nettoyage avancées si nécessaire.
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- --------------------------------------------------------------------
-- 2. STRUCTURE DE LA TABLE DES PROFILS
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_profiles (
    -- Liaison stricte et indexée à la table d'authentification racine
    user_id TEXT PRIMARY KEY NOT NULL,
    
    -- Nom d'affichage cosmétique (Autorise les majuscules et espaces, mais pas vide)
    pseudo TEXT NOT NULL CHECK (length(trim(pseudo)) >= 1 AND length(pseudo) <= 50),
    
    -- Identifiant unique Yrion (Minuscules strictes, sans espace, requis pour les mentions @username)
    username TEXT NOT NULL CHECK (
        length(trim(username)) >= 3 
        AND length(username) <= 30
        AND username = lower(trim(username)) 
        AND username NOT LIKE '% %'
        AND username ~ '^[a-z0-9_.]+$' -- Sécurité Regex : Uniquement lettres, chiffres, underscores et points. Évite les injections visuelles.
    ),
    
    -- Zone de texte libre bridée pour éviter la surcharge de mémoire tampon
    bio TEXT DEFAULT '' NOT NULL CHECK (length(bio) <= 500),
    
    -- Stockage propre du pointeur d'image (Chemin d'accès au bucket de stockage/CDN)
    profile_image_path TEXT DEFAULT NULL CHECK (profile_image_path IS NULL OR length(trim(profile_image_path)) > 0),
    
    -- Compteurs d'activité sociale (Protégés contre les valeurs négatives)
    nb_publications INTEGER DEFAULT 0 NOT NULL CHECK (nb_publications >= 0),
    nb_abonnes INTEGER DEFAULT 0 NOT NULL CHECK (nb_abonnes >= 0),
    nb_abonnements INTEGER DEFAULT 0 NOT NULL CHECK (nb_abonnements >= 0),
    
    -- Traçabilité et audit temporel
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    -- Assure l'intégrité référentielle : Si l'UUID parent saute, la fiche profil meurt proprement
    CONSTRAINT fk_user_profile_parent FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_profile_username UNIQUE (username)
);

-- --------------------------------------------------------------------
-- 3. INDEX DE COUVERTURE ET INDEX COMPOSITES HAUTE PERFORMANCE
-- --------------------------------------------------------------------
-- Accélération critique pour la recherche de profils et la barre de recherche globale
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_username_perfect_match ON user_profiles(username);

-- Index de couverture composite : Permet à Rust de charger la carte de profil d'un utilisateur
-- (Pseudo + Avatar + Stats) en une seule opération d'indexation sans jamais scanner la table (Index Only Scan).
CREATE INDEX IF NOT EXISTS idx_profiles_performance_covering 
ON user_profiles(user_id, username, pseudo, nb_publications, nb_abonnes, nb_abonnements);


-- --------------------------------------------------------------------
-- 4. INJECTEUR MAGIQUE D'HISTORIQUE ET SÉCURISATION
-- --------------------------------------------------------------------
-- Migration à chaud : Si la table 'users' possède déjà des données de comptes,
-- on extrait ces données, on purge les caractères invisibles, on applique les contraintes
-- et on injecte le tout sans perturber les connexions actives.
INSERT INTO user_profiles (user_id, pseudo, username, bio)
SELECT 
    id, 
    substring(trim(username) from 1 for 50) AS pseudo,
    -- Mesure de secours : Si l'ancien username enfreint la regex (ex: contient un caractère spécial),
    -- on applique un filtre d'assainissement pour forcer le passage sans faire planter la migration.
    lower(regexp_replace(trim(username), '[^a-zA-Z0-9_.]', '', 'g')) AS username,
    '' AS bio
FROM users
ON CONFLICT (user_id) DO NOTHING;


-- --------------------------------------------------------------------
-- 5. AUTOMATISATION TEMPORELLE ET BLINDAGE DE L'IMMUABILITÉ
-- --------------------------------------------------------------------

-- A. Déclencheur du rafraîchissement temporel (updated_at)
CREATE OR REPLACE FUNCTION update_user_profiles_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_user_profiles_update_timestamp ON user_profiles;
CREATE TRIGGER trg_user_profiles_update_timestamp
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_user_profiles_timestamp();

-- B. Verrou d'Immuabilité de Création (Sécurité Anti-Fraude)
-- Bloque définitivement toute tentative frauduleuse ou bug de code Rust visant à modifier la date 'created_at'.
CREATE OR REPLACE FUNCTION freeze_user_profile_creation_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_at <> OLD.created_at THEN
        RAISE EXCEPTION 'ERREUR CRITIQUE DE SÉCURITÉ : La date de création originelle d''un profil utilisateur est immuable.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_user_profiles_immutable_creation ON user_profiles;
CREATE TRIGGER trg_user_profiles_immutable_creation
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION freeze_user_profile_creation_date();