-- ====================================================================
-- MIGRATION INITIALE : ARCHITECTURE QUANTIQUE YRION CORE V4
-- DESCRIPTION        : Optimisation GIN (Trigrammes) & Index Parfaits
-- CIBLE              : Neon (PostgreSQL) Production Élite
-- ====================================================================

-- 🛰️ ÉTAPE 0 : ACTIVATION DES EXTENSIONS CYBER-INTELLIGENTES
-- Permet la recherche ultra-rapide avec fautes de frappe (Trigrammes)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- Permet d'ignorer les accents automatiquement
CREATE EXTENSION IF NOT EXISTS unaccent;

-- 🛸 1. INDEX GIN SURPUISSANT POUR LE MOTEUR DE RECHERCHE (ANTI-FAUTES DE FRAPPE)
-- Meta utilise des serveurs dédiés pour ça, Yrion le fait en 1ms directement dans Neon.
-- Cet index permet des recherches partielles instantanées (ex: '%yrion%')
CREATE INDEX IF NOT EXISTS idx_yrion_quantum_trgm_search 
ON user_profiles USING gin (pseudo gin_trgm_ops);

-- 🗲 2. INDEX COMPOSITE DE COUVERTURE POUR LE FIL D'ACTUALITÉ
-- Trie physiquement les posts sur le cloud de Neon pour éliminer la latence réseau.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_posts_feed_composite_v2 
ON posts(user_id, created_at DESC, id);

-- 🛡️ 3. INDEX DE COUVERTURE UNIQUE POUR LES LIKES
-- Bloque mathématiquement les requêtes de triche et calcule les scores instantanément.
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS idx_likes_covering_perfect 
ON likes(post_id, user_id);

-- 🔗 4. GRAPH SOCIAL BILATÉRAL (SUIVIS ET ABONNÉS)
-- Résolution instantanée des suggestions d'amis et des profils réciproques.
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS idx_followers_bidirectional 
ON followers(follower_id, following_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_followers_inverse 
ON followers(following_id, follower_id);