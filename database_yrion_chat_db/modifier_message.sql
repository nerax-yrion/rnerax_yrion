-- ========================================================
-- 👑 MICRO-COMPOSANT : LOGIQUE DE REMPLACEMENT STRICT
-- ========================================================

CREATE OR REPLACE PROCEDURE executer_modification_message(
    p_message_id VARCHAR(255),
    p_nouveau_contenu TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- On écrase directement l'ancien texte. Confidentialité absolue.
    UPDATE messages_normaux 
    SET contenu_texte = p_nouveau_contenu, 
        est_modifie = TRUE 
    WHERE message_id = p_message_id;
END;
$$;