import 'dart:io';

/// ====================================================================
/// YRION SOCIAL ECOSYSTEM : CACHE CENTRALISÉ DE SESSION PROFIL
/// ENGINE INTÉGRÉ POUR BACKEND RUST (AXUM) & CLUSTER NEON POSTGRESQL
/// MOTEUR DE SÉRIALISATION INDUSTRIEL ET DISPONIBILITÉ STRICTE
/// ====================================================================
class ProfilData {
  // 🎯 IDENTIFIANT UNIQUE (UUID v4) requis par le serveur Rust pour cibler la BDD Neon
  static String userId = ""; 
  static String email = ""; 

  // Données textuelles de l'utilisateur connecté
  static String pseudo = "";
  static String username = "";
  static String bio = "";

  // 🌐 AVATAR DISTANT : URL ou chemin stocké sur le cloud Render/Serveur
  static String? urlAvatarDistant;

  // Fichier d'image chargé localement (Mémoire tampon avant l'upload)
  static File? avatarFichierLocal;

  // Statistiques de la capsule (Typées proprement pour correspondre aux entiers du serveur Rust)
  static int nbPublications = 0;
  static int nbAbonnes = 0;
  static int nbTribus = 0;

  /// 🔓 ÉTAPE CHARGEMENT : Injection des données récupérées depuis le serveur lors du Login ou du Sync
  static void initialiserSession({
    required String idConnecte,
    required String emailConnecte,
    required String pseudoConnecte,
    required String usernameConnecte,
    required String bioConnecte,
    required int publications,
    required int abonnes,
    required int tribus,
    String? avatarUrl,
  }) {
    userId = idConnecte;
    email = emailConnecte;
    pseudo = pseudoConnecte;
    username = usernameConnecte;
    bio = bioConnecte;
    nbPublications = publications;
    nbAbonnes = abonnes;
    nbTribus = tribus;
    urlAvatarDistant = avatarUrl;
    avatarFichierLocal = null; // Réinitialisation du tampon local à l'ouverture de session
  }

  /// 🧬 DÉSERIALISATION AUTOMATIQUE : Hydrate instantanément le cache depuis le JSON d'Axum
  /// Évite d'extraire manuellement chaque champ dans tes contrôleurs Flutter.
  static void chargerDepuisJson(Map<String, dynamic> json) {
    // Extraction sécurisée selon la structure exacte retournée par ton backend Rust
    userId = json['id']?.toString() ?? json['user_id']?.toString() ?? "";
    email = json['email']?.toString() ?? "";
    
    // Extraction du sous-bloc 'profil' s'il existe, sinon lecture à la racine
    final profilMap = json['profil'] as Map<String, dynamic>? ?? json;
    
    pseudo = profilMap['pseudo']?.toString() ?? "";
    username = profilMap['nom_utilisateur']?.toString() ?? profilMap['username']?.toString() ?? "";
    bio = profilMap['bio']?.toString() ?? "";
    urlAvatarDistant = profilMap['url_avatar']?.toString() ?? profilMap['profile_image_path'] as String?;
    
    // Parsing ultra-sécurisé des compteurs numériques Rust u64
    nbPublications = int.tryParse(profilMap['nb_publications']?.toString() ?? '0') ?? 0;
    nbAbonnes = int.tryParse(profilMap['nb_abonnes']?.toString() ?? '0') ?? 0;
    nbTribus = int.tryParse(profilMap['nb_tribus']?.toString() ?? '0') ?? 0;
    
    avatarFichierLocal = null;
  }

  /// 🛰️ SÉRIALISATION SORTANTE : Exporte l'état mémoire actuel en Map JSON compatible Rust
  /// Idéal si tu dois sauvegarder une copie locale ou valider un état complet.
  static Map<String, dynamic> toJson() {
    return {
      "id": userId,
      "email": email,
      "profil": {
        "pseudo": pseudo,
        "nom_utilisateur": username,
        "bio": bio,
        "url_avatar": urlAvatarDistant,
        "nb_publications": nbPublications,
        "nb_abonnes": nbAbonnes,
        "nb_tribus": nbTribus,
      }
    };
  }

  /// Fonction pour générer l'initiale de l'utilisateur (Ex: "A" pour Alexandre)
  static String obtenirInitiale() {
    if (pseudo.trim().isEmpty) return "?";
    return pseudo.trim()[0].toUpperCase();
  }

  /// Modifie les textes du profil après validation du serveur Rust
  static void mettreAJourIdentite({
    required String nouveauPseudo,
    required String nouveauUsername,
    required String nouvelleBio,
  }) {
    pseudo = nouveauPseudo;
    username = nouveauUsername;
    bio = nouvelleBio;
  }

  /// Sauvegarde l'image réelle récupérée depuis la galerie ou l'appareil photo
  static void mettreAJourAvatarLocal(File nouveauFichier) {
    avatarFichierLocal = nouveauFichier;
  }

  /// Met à jour l'URL distante reçue par Render après un upload réussi
  static void validerAvatarDistant(String cheminDistant) {
    urlAvatarDistant = cheminDistant;
    avatarFichierLocal = null; // On peut purger le fichier local, l'image est sécurisée sur le cloud
  }

  /// 🧹 DÉCONNEXION : Nettoyage complet des données de la session
  static void fermerSession() {
    userId = "";
    email = "";
    pseudo = "";
    username = "";
    bio = "";
    urlAvatarDistant = null;
    avatarFichierLocal = null;
    nbPublications = 0;
    nbAbonnes = 0;
    nbTribus = 0;
  }
}