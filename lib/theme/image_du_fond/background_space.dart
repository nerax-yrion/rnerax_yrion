// lib/theme/background_space.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🪐 IMPORTATIONS DE TES STRATÉGIES DE COULEURS RADIALES
import 'fond_matin.dart';
import 'fond_midi.dart';
import 'fond_apres_midi.dart';
import 'fond_nuit.dart';

// ⏱️ IMPORTATION DE TON MINUTEUR ULTRA-ÉCOLOGIQUE
import '../timer_de_fond/gestionnaire_temps_complet.dart';

class BackgroundSpace extends StatelessWidget {
  final Widget child;

  const BackgroundSpace({
    super.key, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 📡 L'APK se branche sur la montre centrale du main.dart
    final YrionTimeMode modeActuel = context.watch<GestionnaireTemps>().modeActuel;

    return Scaffold(
      // AnimatedContainer réalise le fondu magique d'un dégradé à l'autre sans saccade
      body: AnimatedContainer(
        duration: const Duration(seconds: 1), // 1 seconde de transition fluide
        width: double.infinity,
        height: double.infinity,
        decoration: _selectionnerFicheDeFond(modeActuel),
        child: SafeArea(
          child: child, // Tes pages (messages, connexion, etc.) se posent par-dessus
        ),
      ),
    );
  }

  /// 🎨 L'aiguilleur chirurgical qui va piocher dans tes fichiers de dégradés
  BoxDecoration _selectionnerFicheDeFond(YrionTimeMode mode) {
    switch (mode) {
      case YrionTimeMode.matin:
        return FondMatin.obtenirDecoration();
      case YrionTimeMode.midi:
        return FondMidi.obtenirDecoration();
      case YrionTimeMode.apresMidi:
        return FondApresMidi.obtenirDecoration();
      case YrionTimeMode.nuit:
        return FondNuit.obtenirDecoration();
    }
  }
}