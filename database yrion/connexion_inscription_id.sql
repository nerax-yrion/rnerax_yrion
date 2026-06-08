-- ====================================================================
-- MODULE 1 : LE COFFRE-FORT DES IDENTITÉS (CONNEXION & INSCRIPTION)
-- ====================================================================

-- Désactive l'écriture si la table existe déjà pour éviter d'écraser des données par erreur
CREATE TABLE IF NOT EXISTS users (
    -- L'identifiant unique mondial (UUID v4 de Rust) stocké sous forme de texte immuable
    id TEXT PRIMARY KEY NOT NULL UNIQUE CHECK(length(id) >= 36),
    
    -- Le nom d'utilisateur : unique, nettoyé, entre 3 et 20 caractères
    username TEXT NOT NULL UNIQUE CHECK(length(trim(username)) >= 3),
    
    -- L'adresse email : unique, format vérifié basique directement par la DB
    email TEXT NOT NULL UNIQUE CHECK(email LIKE '%_@__%.__%'),
    
    -- Le mot de passe haché avec Argon2id (ne sera JAMAIS stocké en texte clair)
    password TEXT NOT NULL CHECK(length(password) > 10),
    
    -- Biographie optionnelle de l'utilisateur d'Yrion
    bio TEXT DEFAULT '',
    
    -- Lien ou chemin vers l'image de profil
    profile_image TEXT DEFAULT '',
    
    -- Statut de sécurité du compte pour la modération mondiale (active, suspendu, banni)
    status TEXT DEFAULT 'active' CHECK(status IN ('active', 'suspended', 'banned')),
    
    -- Horodatage de la création du compte (Date et heure universelle UTC)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- Traceur de sécurité pour détecter les comptes inactifs ou suspecter les piratages
    last_login_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table des paramètres : un prolongement direct du profil utilisateur
CREATE TABLE IF NOT EXISTS settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Liaison obligatoire et sécurisée avec l'UUID de l'utilisateur
    user_id TEXT NOT NULL UNIQUE,
    
    -- Thème de l'interface (Yrion est optimisé pour le blanc épuré 'light')
    theme TEXT DEFAULT 'light' CHECK(theme IN ('light', 'dark')),
    
    -- Gestion des notifications (1 = Activé, 0 = Désactivé)
    notifications INTEGER DEFAULT 1 CHECK(notifications IN (0, 1)),
    
    -- Sécurité absolue : Si l'utilisateur supprime son compte, ses paramètres s'effacent automatiquement
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);