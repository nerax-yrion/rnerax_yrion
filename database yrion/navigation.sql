-- ====================================================================
-- MODULE 2    : LE MOTEUR DE NAVIGATION ET INTERACTIONS SOCIALES
-- DESCRIPTION : FLUX D'ACTUALITÉ, INTERACTIONS ET AGREGATION DYNAMIQUE
-- COMPATIBILITÉ : Rust Axum (Async) & `user_profiles` (profil.sql)
-- ====================================================================

PRAGMA foreign_keys = ON;

-- --------------------------------------------------------------------
-- 1. TABLE DES PUBLICATIONS (LE FLUX D'ACTUALITÉ MONDIAL)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    image TEXT DEFAULT NULL, -- NULL signifie qu'il n'y a pas de capteur visuel lié au post
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 2. TABLE DES MENTIONS "J'AIME" (ANTI-TRAFIC ET DOUBLONS)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS likes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    post_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    
    -- Un utilisateur ne peut mettre qu'UN SEUL like par publication
    UNIQUE(user_id, post_id)
);

-- --------------------------------------------------------------------
-- 3. TABLE DES COMMENTAIRES
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    post_id INTEGER NOT NULL,
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 4. TABLE DES FOLLOWERS (LE RÉSEAU SOCIAL INTERCONNECTÉ)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS followers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    follower_id TEXT NOT NULL, -- Le suiveur
    following_id TEXT NOT NULL, -- Le suivi
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE(follower_id, following_id),
    CONSTRAINT check_not_self_follow CHECK(follower_id <> following_id)
);

-- --------------------------------------------------------------------
-- 5. AUTOMATISATION DES COMPTEURS EN TEMPS RÉEL (TRIGGERS ÉLITE)
-- --------------------------------------------------------------------

-- A. Incrémentation / Décrémentation automatique du nombre de publications du profil
CREATE TRIGGER IF NOT EXISTS trg_posts_count_increment
AFTER INSERT ON posts
BEGIN
    UPDATE user_profiles SET nb_publications = nb_publications + 1 WHERE user_id = NEW.user_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_posts_count_decrement
AFTER DELETE ON posts
BEGIN
    UPDATE user_profiles SET nb_publications = nb_publications - 1 WHERE user_id = OLD.user_id;
END;

-- B. Gestion automatique des abonnés et abonnements lors d'un Follow / Unfollow
CREATE TRIGGER IF NOT EXISTS trg_followers_count_increment
AFTER INSERT ON followers
BEGIN
    -- Augmente le nombre d'abonnés de celui qui est suivi
    UPDATE user_profiles SET nb_abonnes = nb_abonnes + 1 WHERE user_id = NEW.following_id;
    -- Augmente le nombre d'abonnements de celui qui suit
    UPDATE user_profiles SET nb_abonnements = nb_abonnements + 1 WHERE user_id = NEW.follower_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_followers_count_decrement
AFTER DELETE ON followers
BEGIN
    UPDATE user_profiles SET nb_abonnes = nb_abonnes - 1 WHERE user_id = OLD.following_id;
    UPDATE user_profiles SET nb_abonnements = nb_abonnements - 1 WHERE user_id = OLD.follower_id;
END;

-- --------------------------------------------------------------------
-- 6. INDEX DE COUVERTURE POUR LES CASCADES ET RECHERCHES FLUX
-- --------------------------------------------------------------------
-- Évite les scans complets de la base lors des suppressions en cascade (ON DELETE CASCADE)
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_post_id ON likes(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_followers_following_id ON followers(following_id);