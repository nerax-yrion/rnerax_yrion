import 'package:flutter/material.dart';
import 'package:nerax_yrion/services/auth_service.dart';

class InscriptionController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Libère la mémoire des contrôleurs pour éviter les fuites de RAM
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  /// Gestionnaire d'inscription connecté à ton serveur Render
  Future<AuthResult?> handleRegister({
    required BuildContext context,
    required Function(bool) onLoadingChanged,
    required Function(String message, bool isError) showSnackBar,
  }) async {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // 1. Validation rapide côté client (UX de haut niveau)
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showSnackBar("Veuillez remplir tous les champs.", true);
      return null;
    }

    if (password.length < 6) {
      showSnackBar("Le mot de passe doit contenir au moins 6 caractères.", true);
      return null;
    }

    // 2. Activation du chargement dans l'UI
    onLoadingChanged(true);

    // 3. Appel API vers ton serveur FastAPI distant
    final AuthResult result = await _authService.register(email, password, username);

    // 4. Désactivation du chargement dans l'UI
    onLoadingChanged(false);

    // 5. Traitement du résultat
    if (result.success) {
      showSnackBar(result.message ?? "Compte créé avec succès !", false);
      
      // 🚀 REDIRECTION ÉLITE : Redirige vers ton fichier navigation.dart après l'inscription réussie
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {
      // Affichage de l'erreur dynamique renvoyée par le serveur
      showSnackBar(
        result.message ?? "Une erreur est survenue lors de l'inscription.",
        true,
      );
    }
    return result;
  }
}