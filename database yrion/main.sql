-- ====================================================================
-- MODULE CENTRAL : INITIALISATION, OPTIMISATION & SÉCURITÉ CONCURRENTIELLE
-- DESCRIPTION    : Point d'entrée unique de l'écosystème Yrion (Édition Élite)
-- COMPATIBILITÉ : Entièrement synchronisé avec Rust Axum & Flutter Async
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. CONFIGURATION CHIRURGICALE DU MOTEUR (SÉCURITÉ & PERFORMANCE MULTI-THREAD)
-- --------------------------------------------------------------------

-- Force l'activation immédiate des contraintes de clés étrangères
PRAGMA foreign_keys = ON;

-- Active le mode WAL (Write-Ahead Logging). Permet des écritures par Rust 
-- sans jamais bloquer les lectures simultanées de l'application Flutter.
PRAGMA journal_mode = WAL;

-- Synchronisation 'NORMAL' : Le compromis parfait en mode WAL. Les écritures
-- sont regroupées en mémoire avant d'être envoyées sur le disque NVMe. 
-- Supprime les micro-saccades de l'application tout en évitant la corruption.
PRAGMA synchronous = NORMAL;

-- Ajuste la taille du cache en mémoire vive (RAM). Ici, ~80 Mo (20000 pages de 4Ko)
-- dédiés uniquement à garder les index et profils chauds en mémoire pour Rust.
PRAGMA cache_size = -20000;

-- Active le stockage temporaire en RAM plutôt que sur le disque dur pour les
-- tris complexes (comme regrouper les flux de publications ou de followers).
PRAGMA temp_store = MEMORY;

-- Temps d'attente maximum (5 secondes) si la base est verrouillée par une transaction
-- concurrente avant de lever une erreur, laissant le temps à l'asynchronisme de Rust de finir.
PRAGMA busy_timeout = 5000;


-- --------------------------------------------------------------------
-- 2. CHARGEMENT ET CRÉATION DES TABLES (SÉQUENCE CHRONOLOGIQUE STRICTE)
-- --------------------------------------------------------------------

-- Étape A : Le cœur de l'authentification (génère la table racine 'users')
.read connexion_inscription_id.sql

-- Étape B : L'extension d'identité (génère 'user_profiles' rattaché à 'users')
.read profil.sql

-- Étape C : Les briques structurelles de la navigation de l'application
.read navigation.sql


-- --------------------------------------------------------------------
-- 3. INDEX DE PERFORMANCE CLÉS (FLUX DE DONNÉES DE GRANDE ENVERGURE)
-- --------------------------------------------------------------------

-- Note : Les index hautement critiques concernant les emails, pseudonymes uniques
-- et historiques de modification sont gérés à la source dans 'profil.sql' et 'users.sql'.

-- Index composite sur les publications : permet de charger instantanément le fil d'actualité
-- d'un utilisateur trié du plus récent au plus ancien sans aucun tri en mémoire (Zéro-Allocation).
CREATE INDEX IF NOT EXISTS idx_posts_feed_composite ON posts(user_id, created_at DESC);

-- Index de couverture pour les scores de popularité (Accélère le traitement des likes)
CREATE INDEX IF NOT EXISTS idx_likes_covering ON likes(post_id);

-- Index réseau social bilatéral : résout à la vitesse de l'éclair les requêtes de type
-- "Est-ce que l'utilisateur A suit l'utilisateur B ?" et génère les suggestions d'abonnements.
CREATE UNIQUE INDEX IF NOT EXISTS idx_followers_bidirectional ON followers(follower_id, following_id);


-- --------------------------------------------------------------------
-- 4. MAINTENANCE AUTOMATIQUE PROACTIVE
-- --------------------------------------------------------------------

-- Analyse les index créés pour optimiser le planificateur de requêtes interne de SQLite.
-- À chaque démarrage du serveur Rust, la BDD sait exactement quel chemin prendre pour être la plus rapide.
ANALYZE;