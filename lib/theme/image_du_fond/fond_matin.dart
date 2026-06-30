// lib/theme/gradients/fond_matin.dart
import 'package:flutter/material.dart';

class FondMatin {
  static BoxDecoration obtenirDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0B2523), // Vert sapin très sombre nocturne
          Color(0xFF00F5D4), // Vert aurore boréale fluorescent
          Color(0xFF00BBF9), // Bleu polaire aérien
          Color(0xFF03001E), // Noir de l'espace profond
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ),
    );
  }
}