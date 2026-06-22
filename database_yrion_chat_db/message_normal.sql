-- ========================================================
-- 👑 MICRO-COMPOSANT : MESSAGES NORMAUX & MODIFICATIONS
-- ========================================================

CREATE TABLE messages_normaux (
    message_id VARCHAR(255) PRIMARY KEY,
    expediteur_id VARCHAR(40) NOT NULL,
    destinataire_id VARCHAR(40) NOT NULL,
    contenu_texte TEXT NOT NULL,
    est_modifie BOOLEAN DEFAULT FALSE,
    date_envoi TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, -- Optimisé pour le fuseau horaire mondial
    
    -- Sécurité : Évite d'enregistrer des messages vides ou des envois à soi-même
    CONSTRAINT chk_contenu_non_vide CHECK (LENGTH(TRIM(contenu_texte)) > 0),
    CONSTRAINT chk_messages_destinataire_different CHECK (expediteur_id <> destinataire_id)
);