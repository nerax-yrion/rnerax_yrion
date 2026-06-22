-- ========================================================
-- 👑 MICRO-COMPOSANT : PIPELINE MESSAGES VOCAUX
-- ========================================================

CREATE TABLE messages_vocaux (
    vocal_id VARCHAR(255) PRIMARY KEY,
    expediteur_id VARCHAR(40) NOT NULL,
    destinataire_id VARCHAR(40) NOT NULL,
    url_fichier_audio VARCHAR(512) NOT NULL,
    duree_secondes INT NOT NULL,
    date_envoi TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Sécurité : Une note vocale doit avoir une URL valide et une durée positive
    CONSTRAINT chk_duree_positive CHECK (duree_secondes > 0),
    CONSTRAINT chk_url_audio_valide CHECK (url_fichier_audio LIKE 'https://%'),
    CONSTRAINT chk_vocal_destinataire_different CHECK (expediteur_id <> destinataire_id)
);