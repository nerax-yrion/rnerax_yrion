-- ====================================================================
-- FICHIER : migrations/0001_initialisation_yrion.sql
-- DESCRIPTION : Script automatique envoyé à Neon pour créer le coffre-fort
-- ====================================================================

-- 1. TABLE DES UTILISATEURS YRION
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY NOT NULL UNIQUE, -- UUID binaire géré nativement par Neon pour aller super vite
    username VARCHAR(20) NOT NULL UNIQUE, -- Pseudo unique, limité à 20 caractères
    email VARCHAR(255) NOT NULL UNIQUE,   -- Email unique pour les connexions
    password TEXT NOT NULL,                -- Mot de passe qui recevra le hachage Argon2id
    bio TEXT DEFAULT '',
    profile_image TEXT DEFAULT '',
    status VARCHAR(20) DEFAULT 'active',   -- Statut pour bannir ou suspendre un tricheur/hacker
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABLE DES PARAMÈTRES UTILISATEUR
CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY, -- Identifiant numérique généré tout seul par Neon
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE, -- Clé liée à l'utilisateur
    theme VARCHAR(10) DEFAULT 'light', -- Le fameux thème blanc d'Yrion
    notifications INT DEFAULT 1        -- 1 = activé, 0 = désactivé
);

-- 3. TABLE DES PUBLICATIONS (Flux d'accueil de ton application)
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Auteur de la publication
    content TEXT NOT NULL, -- Texte de la publication
    image TEXT,            -- Lien de l'image si présente
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. TABLE DES MENTIONS J'AIME (Likes)
CREATE TABLE IF NOT EXISTS likes (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_post_like UNIQUE(user_id, post_id) -- Bloque les tricheurs : un seul like par post !
);

-- 5. TABLE DES COMMENTAIRES
CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. TABLE DES FOLLOWERS (Le réseau social)
CREATE TABLE IF NOT EXISTS followers (
    id SERIAL PRIMARY KEY,
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,  -- Celui qui s'abonne
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Celui qui est suivi
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_follower_following UNIQUE(follower_id, following_id),
    CONSTRAINT check_not_self_follow CHECK (follower_id <> following_id) -- Interdiction de se suivre soi-même !
);

-- 7. LES INDEX MATÉRIELS DE PERFORMANCE ULTRA-RAPIDE
CREATE INDEX IF NOT EXISTS idx_users_email_search ON users(email);
CREATE INDEX IF NOT EXISTS idx_posts_perf ON posts(user_id, created_at DESC);