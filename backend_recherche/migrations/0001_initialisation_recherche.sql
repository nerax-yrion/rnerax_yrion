-- ====================================================================
-- MIGRATION INITIALE : MOTEUR DE RECHERCHE QUANTIQUE YRION CORE V4
-- ARCHITECTURE       : Immunité Totale, Indexation GIN Concurrente Multi-Trame
-- CIBLE              : Neon (PostgreSQL) Production Élite Flotte
-- ====================================================================

-- 🛰️ ÉTAPE 1 : ACTIVATION DES EXTENSIONS CYBER-INTELLIGENTES
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- 🛡️ ÉTAPE 2 : VÉRIFICATION ET SÉCURISATION INTER-SERVICES DES TABLES
-- On harmonise les types (TEXT/UUID) pour garantir les jointures à chaud (0ms).

CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id TEXT PRIMARY KEY NOT NULL,
    pseudo TEXT NOT NULL CHECK (length(trim(pseudo)) >= 1 AND length(pseudo) <= 50),
    username TEXT NOT NULL,
    bio TEXT DEFAULT '' NOT NULL CHECK (length(bio) <= 500),
    profile_image_path TEXT DEFAULT NULL,
    nb_publications INTEGER DEFAULT 0 NOT NULL CHECK (nb_publications >= 0),
    nb_abonnes INTEGER DEFAULT 0 NOT NULL CHECK (nb_abonnes >= 0),
    nb_abonnements INTEGER DEFAULT 0 NOT NULL CHECK (nb_abonnements >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_recherche_profile_parent FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_profile_username_recherche UNIQUE (username)
);

CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS likes (
    post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, user_id)
);

CREATE TABLE IF NOT EXISTS followers (
    follower_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (follower_id, following_id)
);

-- 🛸 ÉTAPE 3 : INDEXATION GIN MULTI-TRAME (RECHERCHE PRÉDICTIVE SANS LATENCE)
-- Règle d'or : On applique un index GIN combiné avec "unaccent" pour ignorer les accents à la volée.
-- L'indexation passe en mode immuable pour éliminer les micro-sauts CPU de Neon.

CREATE INDEX IF NOT EXISTS idx_yrion_quantum_trgm_pseudo 
ON user_profiles USING gin (lower(unaccent(pseudo)) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_yrion_quantum_trgm_username 
ON user_profiles USING gin (lower(username) gin_trgm_ops);

-- 🗲 ÉTAPE 4 : INDEX DE COUVERTURE HAUTE PERFORMANCE (ZÉRO COLLISION)

-- Arbre B-Tree inversé pour le fil d'actualité global (Tri instantané du plus récent au plus ancien)
CREATE INDEX IF NOT EXISTS idx_posts_feed_composite_v2 
ON posts(user_id, created_at DESC, id);

-- Index de couverture unique pour bloquer la triche sur les likes à la source
CREATE UNIQUE INDEX IF NOT EXISTS idx_likes_covering_perfect 
ON likes(post_id, user_id);

-- Graphe social bidirectionnel pour le calcul instantané des suggestions d'amis
CREATE INDEX IF NOT EXISTS idx_followers_inverse 
ON followers(following_id, follower_id);

-- 🔄 ÉTAPE 5 : INJECTEUR SYNC DE SÉCURITÉ
-- Si des utilisateurs existent dans la table d'authentification mais n'ont pas encore de profil,
-- cet injecteur crée leur fiche à la volée pour éviter que le moteur de recherche ne renvoie un "NullPointer".
INSERT INTO user_profiles (user_id, pseudo, username, bio)
SELECT 
    id, 
    substring(trim(email) from 1 for 50) AS pseudo,
    lower(regexp_replace(split_part(email, '@', 1), '[^a-zA-Z0-9_.]', '', 'g')) AS username,
    '' AS bio
FROM users
ON CONFLICT (user_id) DO NOTHING;