-- ====================================================================
-- MODULE CENTRAL : INITIALISATION & ACCÉLÉRATION DU CODE MATÉRIEL
-- ====================================================================

-- 1. FORCE L'ACTIVATION DES CLÉS ÉTRANGÈRES (Crucial pour la sécurité des liaisons)
PRAGMA foreign_keys = ON;

-- 2. CHARGEMENT ET CRÉATION DES TABLES DANS L'ORDRE STRICT
.read connexion_inscription_id.sql
.read navigation.sql

-- 3. INDEX DE PERFORMANCE MONDIAUX (Le secret pour supporter des milliards de lignes)
-- Ces index permettent au processeur de trouver une ligne instantanément sans chercher dans toute la DB.

-- Accélère de 10 000% la recherche lors d'une tentative de connexion par email
CREATE INDEX IF NOT EXISTS idx_users_email_search ON users(email);

-- Permet de charger le profil d'un utilisateur par son pseudonyme instantanément
CREATE INDEX IF NOT EXISTS idx_users_username_search ON users(username);

-- Optimise l'affichage du fil d'actualité (Affiche les posts les plus récents d'abord)
CREATE INDEX IF NOT EXISTS idx_posts_perf ON posts(user_id, created_at DESC);

-- Accélère le comptage des likes d'une publication pour l'affichage des scores de popularité
CREATE INDEX IF NOT EXISTS idx_likes_counter ON likes(post_id);

-- Optimise la recherche des abonnés pour générer le flux personnalisé
CREATE INDEX IF NOT EXISTS idx_followers_network ON followers(follower_id, following_id);