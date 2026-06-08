import 'package:flutter/material.dart';
import 'connexion_controller.dart';
import 'connexion_validator.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final ConnexionController _controller = ConnexionController();
  
  bool obscurePassword = true;
  bool isLoading = false;

  // Stockage des messages d'erreur à afficher sous les champs de saisie
  String? emailFieldError;
  String? passwordFieldError;

  /// Lance la vérification locale avant d'envoyer la requête réseau
  void _validerEtSeConnecter() {
    setState(() {
      // On demande au validateur d'analyser le texte actuel des contrôleurs
      emailFieldError = ConnexionValidator.validerEmail(_controller.emailController.text);
      passwordFieldError = ConnexionValidator.validerMotDePasse(_controller.passwordController.text);
    });

    // Si une erreur apparaît, on bloque l'envoi vers Render pour protéger ton serveur
    if (emailFieldError != null || passwordFieldError != null) {
      _showCustomSnackBar(message: "Veuillez corriger les erreurs dans le formulaire.", isError: true);
      return;
    }

    // Si tout est parfait, on envoie les données au contrôleur pour l'envoi réel
    _controller.handleLogin(
      context: context,
      onLoadingChanged: (val) => setState(() => isLoading = val),
      showSnackBar: (msg, err) => _showCustomSnackBar(message: msg, isError: err),
    );
  }

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// LOGO PREMIUM OFFICIEL YRION
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
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// TITRE PRINCIPAL
                  const Text(
                    "Connexion",
                    style: TextStyle(
                      color: Color(0xFF0F0F1A),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ZONE SAISIE : EMAIL
                  TextField(
                    controller: _controller.emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      // Efface l'erreur dès que l'utilisateur recommence à écrire
                      if (emailFieldError != null) setState(() => emailFieldError = null);
                    },
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: const TextStyle(color: Colors.white54),
                      errorText: emailFieldError, 
                      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      filled: true,
                      fillColor: const Color(0xFF1C1C2E),
                      prefixIcon: const Icon(Icons.email, color: Colors.cyan),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ZONE SAISIE : MOT DE PASSE
                  TextField(
                    controller: _controller.passwordController,
                    obscureText: obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      if (passwordFieldError != null) setState(() => passwordFieldError = null);
                    },
                    onSubmitted: (_) => _validerEtSeConnecter(),
                    decoration: InputDecoration(
                      hintText: "Mot de passe",
                      hintStyle: const TextStyle(color: Colors.white54),
                      errorText: passwordFieldError, 
                      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      filled: true,
                      fillColor: const Color(0xFF1C1C2E),
                      prefixIcon: const Icon(Icons.lock, color: Colors.purple),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BOUTON LUMINEUX DE CONNEXION (AVEC CHARGEMENT)
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [Colors.cyan, Colors.purple]),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _validerEtSeConnecter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "Se connecter",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// LIEN VERS L'ÉCRAN D'INSCRIPTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Pas de compte ? ",
                        style: TextStyle(color: Color(0xFF555566), fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/inscription'),
                        child: const Text(
                          "Inscription",
                          style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
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

// ficher responsable du disigne