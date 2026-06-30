// lib/theme/gradients/fond_apres_midi.dart
import 'package:flutter/material.dart';

class FondApresMidi {
  static BoxDecoration obtenirDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFF7B2CBF), // Violet néon intense
          Color(0xFFFF007F), // Rose fuchsia cyber
          Color(0xFF050014), // Noir absolu mat
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }
}