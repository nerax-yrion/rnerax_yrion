// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 📦 AJOUT : Pour distribuer le temps partout

// 🎯 IMPORTATIONS DE TES DOSSIERS DE DESIGN
import 'package:nerax_yrion/partie connexion et inscription/connexion/connexion.dart';
import 'package:nerax_yrion/partie connexion et inscription/inscription/inscription.dart';
import 'package:nerax_yrion/iconne_de_navigation/navigation.dart';

// 📡 LE CERVEAU RÉSEAU ET DU TIMER DE FOND D'YRION
import 'chat/panne_connexion/gestionnaire_signal_spatial.dart';
import 'theme/timer_de_fond/gestionnaire_temps_complet.dart'; // ⏱️ AJOUT : Ton timer éco-élite

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🛸 INITIALISATION : On allume le scanner de réseau spatial YO !
  GestionnaireSignalSpatial().initialiserSurveillance();
  
  runApp(
    // 🧠 On injecte le GestionnaireTemps au sommet absolu de l'APK
    ChangeNotifierProvider(
      create: (context) => GestionnaireTemps(),
      child: const YrionApp(),
    ),
  );
}

class YrionApp extends StatelessWidget {
  const YrionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yrion',
      
      // Thème sombre officiel pour ton design d'espace profond
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020205),
        fontFamily: 'Roboto',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),

      // On démarre sur l'aiguilleur de session invisible
      home: const SessionSplasher(),

      // Table des routes de ton APK
      routes: {
        '/connexion': (context) => const ConnexionPage(),
        '/inscription': (context) => const InscriptionPage(),
        '/navigation': (context) => const NavigationPage(),
      },
    );
  }
}

/// 🛸 ÉCRAN DE TRANSITION SECURISE
/// Il sert d'intermédiaire pour éviter les crashs de compilation ou les conflits de nom de classe
class SessionSplasher extends StatefulWidget {
  const SessionSplasher({super.key});

  @override
  State<SessionSplasher> createState() => _SessionSplasherState();
}

class _SessionSplasherState extends State<SessionSplasher> {
  @override
  void initState() {
    super.initState();
    _verifierSessionEtRediriger();
  }

  void _verifierSessionEtRediriger() {
    // On planifie la redirection juste après le premier rendu visuel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Par sécurité visuelle, si le token n'est pas géré ici, on ouvre ton magnifique écran de connexion
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/connexion');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Un simple fond noir de l'espace pendant une fraction de seconde, invisible pour l'utilisateur
    return const Scaffold(
      backgroundColor: Color(0xFF020205),
      body: Center(
        child: SizedBox(),
      ),
    );
  }
}