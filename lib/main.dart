import 'package:flutter/material.dart';
import 'package:nerax_yrion/services/auth_service.dart'; 

// 🎯 IMPORTATIONS EXACTES DE TES DOSSIERS DE DESIGN
import 'package:nerax_yrion/partie connexion et inscription/connexion/connexion.dart';
import 'package:nerax_yrion/partie connexion et inscription/inscription/inscription.dart';
import 'package:nerax_yrion/partie navigation/navigation.dart';

void main() async {
  // Assure l'initialisation complète des composants natifs de Flutter (nécessaire pour le stockage local)
  WidgetsFlutterBinding.ensureInitialized();

  // Instance de ton service d'authentification existant
  final AuthService authService = AuthService();

  // Récupération du token via ton backend/stockage local pour l'Auto-Login
  final String? token = await authService.getToken();

  // Si le token généré par ton serveur est présent, l'APK va directement à l'accueil
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

      // Thème épuré blanc officiel Yrion
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

      // Route de démarrage calculée dynamiquement selon l'état de connexion
      initialRoute: initialRoute,

      // Table des routes de ton APK
      routes: {
        '/connexion': (context) => const ConnexionPage(),
        '/inscription': (context) => const InscriptionPage(),
        '/navigation': (context) => const NavigationPage(),
      },
    );
  }
}