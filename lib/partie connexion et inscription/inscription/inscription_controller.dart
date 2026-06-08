import 'package:flutter/material.dart';
import 'package:nerax_yrion/services/auth_service_connexion_inscription_id.dart';

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

  /// Gère l'envoi des données d'inscription au serveur Rust distant
  Future<void> handleRegister({
    required BuildContext context,
    required Function(bool) onLoadingChanged,
    required Function(String message, bool isError) showSnackBar,
  }) async {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // 1. Activation de l'indicateur de chargement
    onLoadingChanged(true);

    // 2. Appel de ton service d'authentification connecté à Render
    final Map<String, dynamic> result = await _authService.inscrireUtilisateur(
      username: username,
      email: email,
      password: password,
    );

    // 3. Désactivation de l'indicateur de chargement
    onLoadingChanged(false);

    // 4. Analyse de la réponse du serveur
    if (result['success'] == true) {
      showSnackBar(result['message'] ?? "Compte créé avec succès ! Bienvenue sur Yrion.", false);
      
      if (context.mounted) {
        // Redirection instantanée vers l'interface de navigation principale
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {
      // Affichage du message d'erreur précis renvoyé par ton serveur Rust
      showSnackBar(
        result['message'] ?? "Une erreur est survenue lors de l'inscription.",
        true,
      );
    }
  }
}