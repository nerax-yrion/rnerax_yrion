class InscriptionValidator {
  /// Valide le nom d'utilisateur
  static String? validerNom(String value) {
    final String nom = value.trim();
    if (nom.isEmpty) {
      return "Le nom d'utilisateur ne peut pas être vide.";
    }
    if (nom.length < 3) {
      return "Le nom doit contenir au moins 3 caractères.";
    }
    return null; // Aucune erreur
  }

  /// Valide l'adresse email
  static String? validerEmail(String value) {
    final String email = value.trim();
    if (email.isEmpty) {
      return "L'adresse email ne peut pas être vide.";
    }
    // Expression régulière pour valider la structure d'un e-mail
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Format d'email invalide (ex: exemple@yrion.com).";
    }
    return null; // Aucune erreur
  }

  /// Valide la sécurité du mot de passe
  static String? validerMotDePasse(String value) {
    final String password = value.trim();
    if (password.isEmpty) {
      return "Le mot de passe ne peut pas être vide.";
    }
    if (password.length < 8) {
      return "Le mot de passe doit contenir au moins 8 caractères.";
    }
    return null; // Aucune erreur
  }
}