import 'package:flutter/material.dart';
import 'package:nerax_yrion/services/auth_service_connexion_inscription_id.dart';

class ConnexionController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Nettoie la mémoire vive de l'appareil
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  /// Envoie les identifiants au serveur Rust sur Render pour une vraie connexion
  Future<void> handleLogin({
    required BuildContext context,
    required Function(bool) onLoadingChanged,
    required Function(String message, bool isError) showSnackBar,
  }) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // 1. Déclenche l'animation de chargement (le cercle qui tourne)
    onLoadingChanged(true);

    // 2. Appel de ton service réseau connecté à Render
    final Map<String, dynamic> result = await _authService.connecterUtilisateur(
      email: email,
      password: password,
    );

    // 3. Arrêt de l'animation de chargement
    onLoadingChanged(false);

    // 4. Analyse de la réponse de ton serveur Rust
    if (result['success'] == true) {
      showSnackBar(result['message'] ?? "Connexion réussie ! Bienvenue sur Yrion.", false);
      
      if (context.mounted) {
        // Redirection instantanée et sécurisée vers l'interface principale (ton APK)
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {
      // Si les identifiants sont faux ou si le serveur a un problème
      showSnackBar(
        result['message'] ?? "Identifiants incorrects ou problème de serveur.",
        true,
      );
    }
  }
}