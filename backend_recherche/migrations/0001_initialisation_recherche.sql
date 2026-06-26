-- ====================================================================
-- MIGRATION INITIALE : MOTEUR DE RECHERCHE QUANTIQUE YRION CORE V4
-- ARCHITECTURE       : Alignement UUID Élite, Zéro Latence GIN
-- CIBLE              : Neon (PostgreSQL) Production Élite Flotte
-- ====================================================================

-- 🛰️ ÉTAPE 1 : ACTIVATION DES EXTENSIONS CYBER-INTELLIGENTES
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- 🛡️ ÉTAPE 2 : VÉRIFICATION ET SÉCURISATION INTER-SERVICES DES TABLES
-- Alignement total sur le type UUID natif de ta base de production

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY NOT NULL, -- 👈 RECTIFICATION : Passage de TEXT à UUID
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id UUID PRIMARY KEY NOT NULL, -- 👈 RECTIFICATION : Passage de TEXT à UUID
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
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- 👈 RECTIFICATION : UUID
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS likes (
    post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- 👈 RECTIFICATION : UUID
    PRIMARY KEY (post_id, user_id)
);

CREATE TABLE IF NOT EXISTS followers (
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- 👈 RECTIFICATION : UUID
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- 👈 RECTIFICATION : UUID
    PRIMARY KEY (follower_id, following_id)
);

-- 🛸 ÉTAPE 3 : INDEXATION GIN MULTI-TRAME (RECHERCHE PRÉDICTIVE SANS LATENCE)
CREATE INDEX IF NOT EXISTS idx_yrion_quantum_trgm_pseudo 
ON user_profiles USING gin (lower(unaccent(pseudo)) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_yrion_quantum_trgm_username 
ON user_profiles USING gin (lower(username) gin_trgm_ops);

-- 🗲 ÉTAPE 4 : INDEX DE COUVERTURE HAUTE PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_posts_feed_composite_v2 
ON posts(user_id, created_at DESC, id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_likes_covering_perfect 
ON likes(post_id, user_id);

CREATE INDEX IF NOT EXISTS idx_followers_inverse 
ON followers(following_id, follower_id);

-- 🔄 ÉTAPE 5 : INJECTEUR SYNC DE SÉCURITÉ
INSERT INTO user_profiles (user_id, pseudo, username, bio)
SELECT 
    id, 
    substring(trim(email) from 1 for 50) AS pseudo,
    lower(regexp_replace(split_part(email, '@', 1), '[^a-zA-Z0-9_.]', '', 'g')) AS username,
    '' AS bio
FROM users
ON CONFLICT (user_id) DO NOTHING;