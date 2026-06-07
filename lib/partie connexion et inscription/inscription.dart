import 'package:flutter/material.dart';
import 'package:nerax_yrion/services/auth_service.dart'; // Importation de ton service réseau

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instance du service d'authentification

  bool obscurePassword = true;
  bool isLoading = false; // Gestion de l'état de chargement

  /// Fonction premium d'inscription connectée au serveur Render
  void _handleRegister() async {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // 1. Validation rapide côté client (UX de haut niveau)
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showCustomSnackBar(
        message: "Veuillez remplir tous les champs.",
        isError: true,
      );
      return;
    }

    if (password.length < 6) {
      _showCustomSnackBar(
        message: "Le mot de passe doit contenir au moins 6 caractères.",
        isError: true,
      );
      return;
    }

    // 2. Activation du chargement
    setState(() {
      isLoading = true;
    });

    // 3. Appel API vers ton serveur FastAPI distant
    final AuthResult result = await _authService.register(email, password, username);

    // 4. Désactivation du chargement
    setState(() {
      isLoading = false;
    });

    // 5. Traitement du résultat
    if (result.success) {
      _showCustomSnackBar(
        message: result.message ?? "Compte créé avec succès !",
        isError: false,
      );
      
      // 🚀 REDIRECTION ÉLITE : Redirige vers ton fichier navigation.dart après l'inscription réussie
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/navigation');
      }
    } else {
      // Affichage de l'erreur dynamique renvoyée par le serveur (ex: "Cet email existe déjà")
      _showCustomSnackBar(
        message: result.message ?? "Une erreur est survenue lors de l'inscription.",
        isError: true,
      );
    }
  }

  /// Système de notification SnackBar premium
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
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc premium
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

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
                        fit: BoxFit.cover, // Rendu parfait sans déformation
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// TITRE
                  const Text(
                    "Créer un compte",
                    style: TextStyle(
                      color: Color(0xFF0F0F1A), // Texte sombre sur fond blanc
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// USERNAME
                  TextField(
                    controller: usernameController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: "Nom d'utilisateur",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1C1C2E),
                      prefixIcon: const Icon(Icons.person, color: Colors.cyan),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                    onSubmitted: (_) => _handleRegister(), // Valide si on appuie sur Entrée du clavier
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
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
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

                  /// BOUTON INTERACTIF AVEC LOADER
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
                      onPressed: isLoading ? null : _handleRegister, // Désactive le bouton si chargement actif
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
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// LIEN VERS LA CONNEXION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Déjà un compte ? ",
                        style: TextStyle(color: Color(0xFF555566), fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/connexion');
                        },
                        child: const Text(
                          "Connexion",
                          style: TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}