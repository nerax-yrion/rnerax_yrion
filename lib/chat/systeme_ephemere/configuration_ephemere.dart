/// 🪐 **MOTEUR DE SÉCURITÉ CYBER : MESSAGES ÉPHÉMÈRES**
class ConfigurationEphemere {
  
  /// Calcule l'instant t précis d'autodestruction
  static DateTime calculerExpiration(int dureeEnSecondes) {
    return DateTime.now().add(Duration(seconds: dureeEnSecondes));
  }

  /// Convertit les secondes en format ultra-pro compact
  static String formatDureeFormulaire(int totalSecondes) {
    if (totalSecondes < 60) return "$totalSecondes sec";
    if (totalSecondes < 3600) return "${(totalSecondes / 60).floor()} min";
    if (totalSecondes < 86400) return "${(totalSecondes / 3600).floor()} h";
    return "${(totalSecondes / 86400).floor()} jour(s)";
  }
}

// se fichier permmete de clalculer  le temps en foctionement de l'animation 
//et du choisx de l'utilisateur 