// lib/theme/gradients/fond_nuit.dart
import 'package:flutter/material.dart';

class FondNuit {
  static BoxDecoration obtenirDecoration() {
    return const BoxDecoration(
      color: Color(0xFF040209), // Le noir absolu de ton fond en base (0xFF040209)
      gradient: RadialGradient(
        // Le halo lumineux commence pile au niveau du logo en haut au centre
        center: Alignment(0.0, -0.85), 
        radius: 1.3,
        colors: [
          Color(0xFF1D1145), // Le violet électrique brillant derrière ton logo
          Color(0xFF0C0721), // La transition sombre bleutée
          Color(0xFF040209), // Retour au noir d'espace profond sur les côtés et le bas
        ],
        stops: [0.0, 0.45, 1.0],
      ),
    );
  }
}