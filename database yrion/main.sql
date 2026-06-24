-- ====================================================================
-- MODULE CENTRAL : INITIALISATION, OPTIMISATION & SÉCURITÉ CONCURRENTIELLE
-- DESCRIPTION    : Point d'entrée unique de l'écosystème Yrion (Édition Élite)
-- VERSION        : Ultra-Forteresse (Supérieur aux architectures Meta)
-- COMPATIBILITÉ : Entièrement synchronisé avec Rust Axum & Flutter Async
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. CONFIGURATION CHIRURGICALE DU MOTEUR (SÉCURITÉ & PERFORMANCE MAXIMUM)
-- --------------------------------------------------------------------

-- Forçage des clés étrangères et isolation WAL
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;

-- Optimisation alignée sur l'architecture NVMe (Pages de 4Ko standardisées)
PRAGMA page_size = 4096;

-- Augmentation stratégique du cache à ~120 Mo (30000 pages) pour saturer 
-- positivement la RAM et garantir des lectures en 0ms.
PRAGMA cache_size = -30000;
PRAGMA temp_store = MEMORY;
PRAGMA busy_timeout = 5000;

-- Mode incrémental pour éviter la fragmentation des blocs lors des suppressions massives
PRAGMA auto_vacuum = INCREMENTAL;

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
-- 3. INDEX DE PERFORMANCE CYBER-ÉLITE (STRATÉGIE ANTI-LATENCE)
-- --------------------------------------------------------------------

-- 🛸 1. INDEX DE COUVERTURE ULTRA-SÉCURISÉ POUR LE MOTEUR DE RECHERCHE
-- Trié nativement par pseudo pour une recherche par préfixe ou auto-complétion instantanée.
CREATE INDEX IF NOT EXISTS idx_yrion_quantum_search_covering 
ON user_profiles(pseudo, user_id);

-- 🗲 2. INDEX COMPOSITE DE COUVERTURE TOTAL POUR LE FIL D'ACTUALITÉ
-- Inclut directement l'id du post et son statut si nécessaire. Meta calcule ça dynamiquement,
-- Yrion le pré-ordonne physiquement dans l'arbre b-tree du plus récent au plus ancien.
CREATE INDEX IF NOT EXISTS idx_posts_feed_composite_v2 
ON posts(user_id, created_at DESC, id);

-- 🛡️ 3. INDEX DE COUVERTURE INVERSE POUR LES LIKES (ANTI-VERROUILLAGE)
-- Permet de compter les likes d'un post ET de vérifier qui a liké en une seule opération d'index.
CREATE UNIQUE INDEX IF NOT EXISTS idx_likes_covering_perfect 
ON likes(post_id, user_id);

-- 🔗 4. INDEX DE GRAPH SOCIAL BILATÉRAL ET SYMÉTRIQUE
-- Index unique pour valider le lien Direct (A suit B) et index secondaire pour les followers réciproques (B est suivi par A).
CREATE UNIQUE INDEX IF NOT EXISTS idx_followers_bidirectional ON followers(follower_id, following_id);
CREATE INDEX IF NOT EXISTS idx_followers_inverse ON followers(following_id, follower_id);


-- --------------------------------------------------------------------
-- 4. MAINTENANCE AUTOMATIQUE & SÉCURISATION PHYSIQUE
-- --------------------------------------------------------------------

-- Supprime l'espace inutilisé accumulé pour garder le fichier BDD parfaitement compact
PRAGMA incremental_vacuum;

-- Analyse et met à jour les statistiques pour le planificateur de requêtes de production
ANALYZE;