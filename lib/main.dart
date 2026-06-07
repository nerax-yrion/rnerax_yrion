import 'package:flutter/material.dart';
import 'package:nerax_yrion/services/auth_service.dart'; // 🛠️ Correction de la faute de frappe (r ajouté)
import 'package:nerax_yrion/partie connexion et inscription/connexion.dart';
import 'package:nerax_yrion/partie connexion et inscription/inscription.dart'; 
import 'package:nerax_yrion/partie navigation/navigation.dart'; // 🛠️ Correction du chemin selon ton dossier "partie navigation"

void main() async {
  // Assure l'initialisation complète des composants natifs de Flutter avant le lancement
  WidgetsFlutterBinding.ensureInitialized();

  // Instance de ton service d'authentification premium
  final AuthService authService = AuthService();

  // Lecture ultra-sécurisée du token au démarrage pour l'Auto-Login
  final String? token = await authService.getToken();

  // Si un token valide existe, on dirige directement vers la navigation principale, sinon vers la connexion
  final String initialRoute = token != null ? '/navigation' : '/connexion';

  runApp(YrionApp(initialRoute: initialRoute));
}

class YrionApp extends StatelessWidget {
  final String initialRoute;

  const YrionApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'yrion',

      // Configuration du thème épuré blanc demandé pour ton interface d'élite
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF0F0F1A)),
        ),
      ),

      // Définition de la route de démarrage dynamique
      initialRoute: initialRoute,

      // Registre centralisé des routes de l'application (Architecture Élite)
      routes: {
        '/connexion': (context) => const ConnexionPage(),
        '/inscription': (context) => const InscriptionPage(),
        '/navigation': (context) => const NavigationPage(), // Ton fichier navigation.dart est connecté !
      },
    );
  }
}