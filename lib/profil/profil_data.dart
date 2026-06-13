import 'dart:io';

class ProfilData {
  // 🎯 Identifiant unique requis par le serveur Rust pour cibler la BDD
  static String email = ""; 

  // Données textuelles de l'utilisateur connecte
  static String pseudo = "";
  static String username = "";
  static String bio = "";

  // Statistiques de la capsule (mises en variables pour accueillir les vrais chiffres du serveur)
  static String nbPublications = "0";
  static String nbAbonnes = "0";
  static String nbTribus = "0";

  // Fichier d'image charge localement
  static File? avatarFichierLocal;

  /// 🔓 ÉTAPE CHARGEMENT : Injection des donnees recuperees depuis le serveur lors du Login
  static void initialiserSession({
    required String emailConnecte,
    required String pseudoConnecte,
    required String usernameConnecte,
    required String bioConnecte,
    required String publications,
    required String abonnes,
    required String tribus,
  }) {
    email = emailConnecte;
    pseudo = pseudoConnecte;
    username = usernameConnecte;
    bio = bioConnecte;
    nbPublications = publications;
    nbAbonnes = abonnes;
    nbTribus = tribus;
  }

  /// Fonction pour generer l'initiale de l'utilisateur (Ex: "A" pour Alexandre)
  static String obtenirInitiale() {
    if (pseudo.trim().isEmpty) return "?";
    return pseudo.trim()[0].toUpperCase();
  }

  /// Modifie les textes du profil apres validation du serveur Rust
  static void mettreAJourIdentite({
    required String nouveauPseudo,
    required String nouveauUsername,
    required String nouvelleBio,
  }) {
    pseudo = nouveauPseudo;
    username = nouveauUsername;
    bio = nouvelleBio;
  }

  /// Sauvegarde l'image reelle recuperee depuis la galerie ou l'appareil photo
  static void mettreAJourAvatar(File nouveauFichier) {
    avatarFichierLocal = nouveauFichier;
  }

  /// 🧹 DECONNEXION : Nettoyage complet des donnees de la session
  static void fermerSession() {
    email = "";
    pseudo = "";
    username = "";
    bio = "";
    nbPublications = "0";
    nbAbonnes = "0";
    nbTribus = "0";
    avatarFichierLocal = null;
  }
}