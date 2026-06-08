-- ====================================================================
-- MODULE 2 : LE MOTEUR DE NAVIGATION ET INTERACTIONS SOCIALES
-- ====================================================================

-- Table des publications (Le flux d'actualité mondial)
CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- ID de l'auteur du post (lié à l'UUID v4 de la table users)
    user_id TEXT NOT NULL,
    
    -- Contenu textuel de la publication (ne peut pas être vide)
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    
    -- Image optionnelle attachée au post
    image TEXT,
    
    -- Date et heure précise de la publication
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Si le compte utilisateur est supprimé, toutes ses publications disparaissent
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des mentions "J'aime" (Anti-Trafic et doublons)
CREATE TABLE IF NOT EXISTS likes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    post_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    
    -- CLAUSE ULTRA-ROBUSTE : Un utilisateur ne peut mettre qu'UN SEUL like par publication
    UNIQUE(user_id, post_id)
);

-- Table des commentaires
CREATE TABLE IF NOT EXISTS comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    post_id INTEGER NOT NULL,
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

-- Table des Followers (Le réseau social interconnecté)
CREATE TABLE IF NOT EXISTS followers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- L'utilisateur qui s'abonne (Le suiveur)
    follower_id TEXT NOT NULL,
    
    -- L'utilisateur qui reçoit l'abonnement (Le suivi)
    following_id TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- SÉCURITÉ : Un utilisateur ne peut pas s'abonner deux fois à la même personne
    UNIQUE(follower_id, following_id),
    
    -- SÉCURITÉ EXTRA : Interdiction stricte de s'abonner à soi-même
    CONSTRAINT check_not_self_follow CHECK(follower_id <> following_id)
);