import 'package:flutter/material.dart';
import 'package:nerax_yrion/services/auth_service.dart'; // Importation de ton service réseau

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instance du service d'authentification

  bool obscurePassword = true;
  bool isLoading = false; // Variable d'état pour gérer le chargement mondial

  /// Fonction premium de gestion de connexion connectée au serveur Render
  void _handleLogin() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // 1. Validation rapide côté client (UX de haut niveau)
    if (email.isEmpty || password.isEmpty) {
      _showCustomSnackBar(
        message: "Veuillez remplir tous les champs.",
        isError: true,
      );
      return;
    }

    // 2. Activation du chargement
    setState(() {
      isLoading = true;
    });

    // 3. Appel API vers ton serveur FastAPI distant
    final AuthResult result = await _authService.login(email, password);

    // 4. Désactivation du chargement
    setState(() {
      isLoading = false;
    });

    // 5. Traitement du résultat
    if (result.success) {
      _showCustomSnackBar(
        message: "Connexion réussie ! Bienvenue sur yrion.",
        isError: false,
      );
      
      // 🚀 REDIRECTION ÉLITE : Envoie l'utilisateur vers ton fichier navigation.dart après connexion réussie
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {
      // Affichage de l'erreur dynamique renvoyée par le serveur
      _showCustomSnackBar(
        message: result.message ?? "Une erreur d'authentification est survenue.",
        isError: true,
      );
    }
  }

  /// Système de notification SnackBar personnalisé digne d'une grande startup
  void _showCustomSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent.shade400 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc premium appliqué ici
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // Évite les bugs d'affichage quand le clavier s'ouvre
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// LOGO PREMIUM OFFICIEL CENTRÉ
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        "assets/yrion_logo_premium.png",
                        fit: BoxFit.cover, // Ne déforme jamais l'icône, rendu parfait
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// TITRE
                  const Text(
                    "Connexion",
                    style: TextStyle(
                      color: Color(0xFF0F0F1A), // Texte sombre pour s'adapter au fond blanc
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// EMAIL
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1C1C2E),
                      prefixIcon: const Icon(Icons.email, color: Colors.cyan),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(), // Valide si on appuie sur Entrée
                    decoration: InputDecoration(
                      hintText: "Mot de passe",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1C1C2E),
                      prefixIcon: const Icon(Icons.lock, color: Colors.purple),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BOUTON INTERACTIF AVEC LOADER INTERNE
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.cyan,
                          Colors.purple,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin, // Désactive le bouton pendant le chargement
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Se connecter",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// LINK INSCRIPTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Pas de compte ? ",
                        style: TextStyle(color: Color(0xFF555566), fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Utilisation du routage nommé pour aller vers l'inscription
                          Navigator.pushNamed(context, '/inscription');
                        },
                        child: const Text(
                          "Inscription",
                          style: TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}