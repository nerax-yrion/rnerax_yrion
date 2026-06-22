-- ========================================================
-- 👑 MICRO-COMPOSANT : SESSIONS APPELS NORMAUX (AUDIO)
-- ========================================================

CREATE TABLE appels_normaux (
    appel_id VARCHAR(255) PRIMARY KEY,
    emetteur_id VARCHAR(40) NOT NULL,
    recepteur_id VARCHAR(40) NOT NULL,
    statut_etape VARCHAR(50) NOT NULL, 
    session_sdp TEXT,
    date_creation TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Sécurité : Cycle de vie de l'appel tracé proprement
    CONSTRAINT chk_statut_audio CHECK (statut_etape IN ('initialisation', 'sonnerie', 'en_cours', 'termine', 'manque', 'rejete')),
    CONSTRAINT chk_appel_different CHECK (emetteur_id <> recepteur_id)
);