import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- AJOUT UNIQUE
import 'package:nerax_yrion/services/auth_service_connexion_inscription_id.dart';

class InscriptionController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> handleRegister({
    required BuildContext context,
    required Function(bool) onLoadingChanged,
    required Function(String message, bool isError) showSnackBar,
  }) async {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // Validation rapide côté Front pour éviter des requêtes réseau inutiles
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showSnackBar("Tous les champs sont obligatoires !", true);
      return;
    }

    onLoadingChanged(true);

    final Map<String, dynamic> result = await _authService.inscrireUtilisateur(
      username: username,
      email: email,
      password: password,
    );

    onLoadingChanged(false);

    if (result['success'] == true) {
      // 🔥 CRITIQUE : Sauvegarde locale des informations saisies avant la redirection
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_username', username);
      await prefs.setString('user_email', email);
      // Si ton serveur renvoie une URL d'avatar par défaut, sauvegarde-la aussi :
      if (result['avatar_url'] != null) {
        await prefs.setString('user_avatar', result['avatar_url']);
      }

      showSnackBar(result['message'] ?? "Compte créé avec succès ! Bienvenue sur Yrion.", false);
      
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {
      showSnackBar(
        result['message'] ?? "Une erreur est survenue lors de l'inscription.",
        true,
      );
    }
  }
}