-- ====================================================================
-- MODULE 1    : LE COFFRE-FORT DES IDENTITÉS (CONNEXION & INSCRIPTION)
-- DESCRIPTION : AUTHENTIFICATION STRICTE, AUDIT ET SÉCURITÉ PÉRENNALISÉE
-- ====================================================================

PRAGMA foreign_keys = ON;

-- --------------------------------------------------------------------
-- 1. TABLE PRINCIPALE : LES CREDENTIALS D'ACCÈS
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    -- UUID v4 mondialement unique et immuable
    id TEXT PRIMARY KEY NOT NULL UNIQUE CHECK(length(id) >= 36),
    
    -- Email normalisé, purgé et structuré (Contrainte regex SQLite native)
    email TEXT NOT NULL UNIQUE CHECK(
        email LIKE '%_@__%.__%' 
        AND email = lower(trim(email))
        AND email NOT LIKE '% %'
    ),
    
    -- Empreinte cryptographique Argon2id (Format PHC strict : $argon2id$v=...)
    password TEXT NOT NULL CHECK(
        length(password) >= 60 
        AND password LIKE '$argon2id$%'
    ),
    
    -- Cycle de vie du compte (Machine d'état fermée)
    status TEXT DEFAULT 'active' NOT NULL CHECK(status IN ('active', 'suspended', 'banned')),
    
    -- Registres temporels immuables
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_login_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- --------------------------------------------------------------------
-- 2. TABLE DES PARAMÈTRES (PRÉFÉRENCES SYSTÈME)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL UNIQUE,
    theme TEXT DEFAULT 'light' NOT NULL CHECK(theme IN ('light', 'dark')),
    notifications INTEGER DEFAULT 1 NOT NULL CHECK(notifications IN (0, 1)),
    
    -- Cascade matérielle totale en cas de suppression
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 3. TABLE D'AUDIT : LE JOURNAL DE SÉCURITÉ INVIOLABLE (AJOUT ÉLITE)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS security_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    action_type TEXT NOT NULL CHECK(action_type IN ('CREATION', 'PASSWORD_CHANGED', 'STATUS_CHANGED', 'SUSPICIOUS_LOGIN')),
    old_value TEXT DEFAULT NULL,
    new_value TEXT DEFAULT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


-- --------------------------------------------------------------------
-- 4. LOGIQUE ACTIVE SÉCURISÉE (TRIGGERS / DÉCLENCHEURS)
-- --------------------------------------------------------------------

-- Déclencheur A : Journalise automatiquement la création d'un compte
CREATE TRIGGER IF NOT EXISTS trg_audit_user_creation
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO security_logs (user_id, action_type, new_value)
    VALUES (NEW.id, 'CREATION', 'Compte créé avec l''e-mail : ' || NEW.email);
END;

-- Déclencheur B : Journalise automatiquement tout changement de mot de passe
CREATE TRIGGER IF NOT EXISTS trg_audit_password_change
AFTER UPDATE OF password ON users
FOR EACH ROW
BEGIN
    INSERT INTO security_logs (user_id, action_type, old_value, new_value)
    VALUES (NEW.id, 'PASSWORD_CHANGED', OLD.password, NEW.password);
END;

-- Déclencheur C : Journalise les actions de modération (Bannissements / Suspensions)
CREATE TRIGGER IF NOT EXISTS trg_audit_status_change
AFTER UPDATE OF status ON users
FOR EACH ROW
WHEN OLD.status <> NEW.status
BEGIN
    INSERT INTO security_logs (user_id, action_type, old_value, new_value)
    VALUES (NEW.id, 'STATUS_CHANGED', OLD.status, NEW.status);
END;

-- Déclencheur D : Verrouille la date de création pour empêcher la falsification de l'historique
CREATE TRIGGER IF NOT EXISTS trg_users_immutable_registration
BEFORE UPDATE OF created_at ON users
FOR EACH ROW
BEGIN
    SELECT RAISE(FAIL, 'CRITICAL SECURITY ERROR : La date de création d''une entité d''accès ne peut être falsifiée.');
END;


-- --------------------------------------------------------------------
-- 5. INDEXATION RAPIDE COMPOSITE
-- --------------------------------------------------------------------

-- Index de couverture unique : Recherche instantanée lors du Login Rust
CREATE UNIQUE INDEX IF NOT EXISTS idx_auth_email_perf ON users(email);

-- Index d'audit : Permet à ton panneau d'administration de lister les logs d'un utilisateur sans ralentir la DB
CREATE INDEX IF NOT EXISTS idx_security_logs_user ON security_logs(user_id, timestamp DESC);