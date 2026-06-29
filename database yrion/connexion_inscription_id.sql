-- ====================================================================
-- MODULE 1    : LE COFFRE-FORT DES IDENTITÉS (CONNEXION & INSCRIPTION)
-- DESCRIPTION : AUTHENTIFICATION STRICTE, AUDIT ET SÉCURITÉ PÉRENNALISÉE
-- COMPATIBILITÉ : POSTGRESQL (Édition Élite Yrion pour Neon)
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. TABLE PRINCIPALE : LES CREDENTIALS D'ACCÈS
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    -- UUID v4 mondialement unique et immuable
    id TEXT PRIMARY KEY NOT NULL UNIQUE CHECK(length(id) >= 36),
    
    -- Email normalisé, purgé et structuré (Contrainte PostgreSQL native)
    email TEXT NOT NULL UNIQUE CHECK (
        email LIKE '%_@__%.__%' 
        AND email = lower(trim(email))
        AND email NOT LIKE '% %'
    ),
    
    -- Empreinte cryptographique Argon2id (Format PHC strict : $argon2id$v=...)
    password TEXT NOT NULL CHECK (
        length(password) >= 60 
        AND password LIKE '$argon2id$%'
    ),
    
    -- Cycle de vie du compte (Machine d'état fermée)
    status TEXT DEFAULT 'active' NOT NULL CHECK(status IN ('active', 'suspended', 'banned')),
    
    -- Registres temporels immuables (Syntaxe PostgreSQL standardisée)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_login_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- --------------------------------------------------------------------
-- ⚡ INTÉGRATION : TABLE DES SESSIONS (POUR TON NOUVEAU SERVEUR TOKEN)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sessions (
    -- Le hash du jeton d'accès unique généré par ton serveur Rust
    token_hash VARCHAR(255) PRIMARY KEY NOT NULL,
    
    -- Clé étrangère liée physiquement à l'id de la table users
    user_id TEXT NOT NULL,
    
    -- Date d'émission de la session
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    -- Liaison physique indestructible (Si le compte saute, la session saute)
    CONSTRAINT fk_user_session
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 2. TABLE DES PARAMÈTRES (PRÉFÉRENCES SYSTÈME)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY, -- Syntaxe PostgreSQL pour l'auto-incrémentation
    user_id TEXT NOT NULL UNIQUE,
    theme TEXT DEFAULT 'light' NOT NULL CHECK(theme IN ('light', 'dark')),
    notifications INT DEFAULT 1 NOT NULL CHECK(notifications IN (0, 1)),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 3. TABLE D'AUDIT : LE JOURNAL DE SÉCURITÉ INVIOLABLE
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS security_logs (
    log_id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    action_type TEXT NOT NULL CHECK(action_type IN ('CREATION', 'PASSWORD_CHANGED', 'STATUS_CHANGED', 'SUSPICIOUS_LOGIN')),
    old_value TEXT DEFAULT NULL,
    new_value TEXT DEFAULT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 4. LOGIQUE ACTIVE SÉCURISÉE (TRIGGERS POSTGRESQL AVEC FONCTIONS STRUCTURELLES)
-- --------------------------------------------------------------------

-- Déclencheur A : Journalise automatiquement la création d'un compte
CREATE OR REPLACE FUNCTION func_audit_user_creation() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO security_logs (user_id, action_type, new_value)
    VALUES (NEW.id, 'CREATION', 'Compte créé avec l''e-mail : ' || NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_audit_user_creation
AFTER INSERT ON users
FOR EACH ROW EXECUTE FUNCTION func_audit_user_creation();


-- Déclencheur B : Journalise automatiquement tout changement de mot de passe
CREATE OR REPLACE FUNCTION func_audit_password_change() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO security_logs (user_id, action_type, old_value, new_value)
    VALUES (NEW.id, 'PASSWORD_CHANGED', OLD.password, NEW.password);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_audit_password_change
AFTER UPDATE OF password ON users
FOR EACH ROW EXECUTE FUNCTION func_audit_password_change();


-- Déclencheur C : Journalise les actions de modération (Bannissements / Suspensions)
CREATE OR REPLACE FUNCTION func_audit_status_change() 
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO security_logs (user_id, action_type, old_value, new_value)
        VALUES (NEW.id, 'STATUS_CHANGED', OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_audit_status_change
AFTER UPDATE OF status ON users
FOR EACH ROW EXECUTE FUNCTION func_audit_status_change();


-- Déclencheur D : Verrouille la date de création pour empêcher la falsification de l'historique
CREATE OR REPLACE FUNCTION func_users_immutable_registration() 
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.created_at <> NEW.created_at THEN
        RAISE EXCEPTION 'CRITICAL SECURITY ERROR : La date de création d''une entité d''accès ne peut être falsifiée.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_users_immutable_registration
BEFORE UPDATE OF created_at ON users
FOR EACH ROW EXECUTE FUNCTION func_users_immutable_registration();

-- --------------------------------------------------------------------
-- 5. INDEXATION RAPIDE COMPOSITE (STRATÉGIE ANTI-LATENCE)
-- --------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS idx_auth_email_perf ON users(email);
CREATE INDEX IF NOT EXISTS idx_security_logs_user ON security_logs(user_id, timestamp DESC);

-- Index de performance Cyber-Élite pour ton Splash Screen Rust / Flutter
CREATE INDEX IF NOT EXISTS idx_sessions_token_perf ON sessions(token_hash);