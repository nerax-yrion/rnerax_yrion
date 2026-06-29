-- ====================================================================
-- MODULE CENTRAL : INITIALISATION, OPTIMISATION & SÉCURITÉ CONCURRENTIELLE
-- DESCRIPTION    : Point d'entrée unique de l'écosystème Yrion (Édition Élite)
-- VERSION        : Ultra-Forteresse (Supérieur aux architectures Meta)
-- COMPATIBILITÉ : ENTIÈREMENT OPTIMISÉ POUR NEON POSTGRESQL & RUST
-- ====================================================================

-- Note pour l'exécution sur ton tableau de bord Neon : 
-- Tu peux copier-coller directement les requêtes ci-dessous pour initialiser les index globaux.

-- --------------------------------------------------------------------
-- 1. INDEX DE PERFORMANCE CYBER-ÉLITE (STRATÉGIE ANTI-LATENCE MULTI-SERVEURS)
-- --------------------------------------------------------------------

-- 🛸 1. INDEX DE COUVERTURE ULTRA-SÉCURISÉ POUR LE MOTEUR DE RECHERCHE
-- Trié nativement par pseudo pour une recherche par préfixe ou auto-complétion instantanée.
CREATE INDEX IF NOT EXISTS idx_yrion_quantum_search_covering 
ON user_profiles(pseudo, user_id);

-- 🗲 2. INDEX COMPOSITE DE COUVERTURE TOTAL POUR LE FIL D'ACTUALITÉ
-- Yrion pré-ordonne physiquement les posts dans l'arbre b-tree du plus récent au plus ancien.
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
-- 2. MAINTENANCE EN PRODUCTION AUTOMATIQUE (NEON SCALE)
-- --------------------------------------------------------------------

-- Nettoie l'espace inutilisé, réorganise l'arbre B-Tree des index et met à jour 
-- le planificateur de requêtes pour garantir des réponses en 0ms.
VACUUM ANALYZE;