import 'package:flutter/material.dart';
import 'package:nerax_yrion/services/auth_service.dart';

class ConnexionController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Libère la mémoire des contrôleurs (à appeler dans le dispose du Widget)
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  /// Gestionnaire de connexion qui récupère les champs complétés
  Future<AuthResult?> handleLogin({
    required BuildContext context,
    required Function(bool) onLoadingChanged,
    required Function(String message, bool isError) showSnackBar,
  }) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // 1. Validation rapide côté client
    if (email.isEmpty || password.isEmpty) {
      showSnackBar("Veuillez remplir tous les champs.", true);
      return null;
    }

    // 2. Activation du chargement dans l'UI
    onLoadingChanged(true);

    // 3. Appel API vers ton serveur FastAPI distant
    final AuthResult result = await _authService.login(email, password);

    // 4. Désactivation du chargement dans l'UI
    onLoadingChanged(false);

    // 5. Traitement du résultat
    if (result.success) {
      showSnackBar("Connexion réussie ! Bienvenue sur yrion.", false);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {
      showSnackBar(
        result.message ?? "Une erreur d'authentification est survenue.",
        true,
      );
    }
    return result;
  }
}