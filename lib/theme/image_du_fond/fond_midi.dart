// lib/theme/gradients/fond_midi.dart
import 'package:flutter/material.dart';

class FondMidi {
  static BoxDecoration obtenirDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF4500), // Orange braise solaire
          Color(0xFFFF9E00), // Jaune néon cosmique
          Color(0xFFFAF0E6), // Blanc sable stellaire épuré
        ],
      ),
    );
  }
}