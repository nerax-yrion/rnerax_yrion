import 'dart:io';

class ProfilData {
  // Données textuelles modifiables par l'utilisateur
  static String pseudo = "Alexandre";
  static String username = "astronaute_du_974";
  static String bio = "Explorateur de tribus • Code & Streetwear ⚡";

  // Statistiques de la capsule
  static const String nbPublications = "142";
  static const String nbAbonnes = "1.2K";
  static const String nbTribus = "8";

  // Plus AUCUN lien d'image internet en dur !
  static File? avatarFichierLocal;

  /// Fonction pour générer l'initiale de l'utilisateur (Ex: "A" pour Alexandre)
  static String obtenirInitiale() {
    if (pseudo.trim().isEmpty) return "?";
    return pseudo.trim()[0].toUpperCase();
  }

  /// Modifie les textes du profil
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
  static void mettreAJourAvatar(File nouveauFichier) {
    avatarFichierLocal = nouveauFichier;
  }
}