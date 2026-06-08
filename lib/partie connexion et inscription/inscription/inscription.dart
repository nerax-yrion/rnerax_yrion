import 'package:flutter/material.dart';
import 'inscription_controller.dart';
import 'inscription_validator.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final InscriptionController _controller = InscriptionController();

  bool obscurePassword = true;
  bool isLoading = false;

  // États locaux pour afficher dynamiquement les erreurs en rouge sous chaque champ
  String? usernameFieldError;
  String? emailFieldError;
  String? passwordFieldError;

  /// Lance les vérifications du validateur avant de soumettre au contrôleur
  void _validerEtSInscrire() {
    setState(() {
      usernameFieldError = InscriptionValidator.validerNom(_controller.usernameController.text);
      emailFieldError = InscriptionValidator.validerEmail(_controller.emailController.text);
      passwordFieldError = InscriptionValidator.validerMotDePasse(_controller.passwordController.text);
    });

    // Si un champ contient une erreur, on bloque la requête réseau pour guider l'utilisateur
    if (usernameFieldError != null || emailFieldError != null || passwordFieldError != null) {
      _showCustomSnackBar(message: "Veuillez corriger les erreurs dans le formulaire.", isError: true);
      return;
    }

    // Tout est correct, on passe à l'inscription réelle sur le serveur
    _controller.handleRegister(
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
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// TITRE
                  const Text(
                    "Créer un compte",
                    style: TextStyle(
                      color: Color(0xFF0F0F1A),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CHAMP : NOM D'UTILISATEUR
                  TextField(
                    controller: _controller.usernameController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      if (usernameFieldError != null) setState(() => usernameFieldError = null);
                    },
                    decoration: InputDecoration(
                      hintText: "Nom d'utilisateur",
                      hintStyle: const TextStyle(color: Colors.white54),
                      errorText: usernameFieldError,
                      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      filled: true,
                      fillColor: const Color(0xFF1C1C2E),
                      prefixIcon: const Icon(Icons.person, color: Colors.cyan),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// CHAMP : EMAIL
                  TextField(
                    controller: _controller.emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
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

                  /// CHAMP : MOT DE PASSE
                  TextField(
                    controller: _controller.passwordController,
                    obscureText: obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      if (passwordFieldError != null) setState(() => passwordFieldError = null);
                    },
                    onSubmitted: (_) => _validerEtSInscrire(),
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

                  /// BOUTON INTERACTIF AVEC LOADER
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [Colors.cyan, Colors.purple]),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _validerEtSInscrire,
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
                              "S'inscrire",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                          style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
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