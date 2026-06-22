-- ========================================================
-- 👑 CHEF D'ORCHESTRE SCRIPT : UNIFICATION DU NOYAU YRION
-- ⚡ EXECUTER CE FICHIER UNIQUE POUR TOUT INSTALLER
-- ========================================================

-- Phase A : Nettoyage propre de la zone spatiale (Ordre strict des dépendances)
DROP PROCEDURE IF EXISTS executer_modification_message;
DROP TABLE IF EXISTS appels_video CASCADE;
DROP TABLE IF EXISTS appels_normaux CASCADE;
DROP TABLE IF EXISTS messages_vocaux CASCADE;
DROP TABLE IF EXISTS messages_normaux CASCADE;

-- Phase B : Chargement des Micro-Composants structurels
\i message_normal.sql
\i message_vocal.sql
\i appel_normal.sql
\i appel_video.sql

-- Phase C : Chargement des Moteurs Logiques
\i modifier_message.sql

-- Phase D : Indexation Quantique Globale pour Débit Massif (1 Milliared de lignes)
-- Index B-Tree composites optimisés pour les requêtes asynchrones bilatérales
CREATE INDEX idx_messages_normaux_flux ON messages_normaux (expediteur_id, destinataire_id, date_envoi DESC);
CREATE INDEX idx_messages_vocaux_flux ON messages_vocaux (expediteur_id, destinataire_id, date_envoi DESC);
CREATE INDEX idx_appels_normaux_flux ON appels_normaux (emetteur_id, recepteur_id, date_creation DESC);
CREATE INDEX idx_appels_video_flux ON appels_video (emetteur_id, recepteur_id, date_creation DESC);

-- Index partiels pour accélérer les requêtes spécifiques du chat
CREATE INDEX idx_messages_normaux_modifies ON messages_normaux (message_id) WHERE est_modifie = TRUE;

-- Affichage de validation dans la console du serveur PostgreSQL
SELECT '👑 ARCHITECTURE MONDIALE YRION CHAT CORRECTEMENT DEPLOYEE AVEC SUCCES !' AS statut_initialisation;