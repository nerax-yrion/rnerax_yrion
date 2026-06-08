class ConnexionValidator {
  /// Valide le champ Email en temps réel ou à la soumission
  static String? validerEmail(String value) {
    final String email = value.trim();
    
    if (email.isEmpty) {
      return "L'adresse email ne peut pas être vide.";
    }
    
    // Expression régulière pour valider le format de l'email
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Format d'email invalide (ex: exemple@yrion.com).";
    }
    
    return null; // Tout est bon, pas d'erreur
  }

  /// Valide le champ Mot de passe
  static String? validerMotDePasse(String value) {
    final String password = value.trim();
    
    if (password.isEmpty) {
      return "Le mot de passe ne peut pas être vide.";
    }
    
    if (password.length < 8) {
      return "Le mot de passe doit contenir au moins 8 caractères.";
    }
    
    return null; // Tout est bon, pas d'erreur
  }
}