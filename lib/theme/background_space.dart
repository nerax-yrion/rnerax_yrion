import 'package:flutter/material.dart';
import '../theme/yrion_theme.dart';

class BackgroundSpace extends StatelessWidget {
  final Widget child;

  const BackgroundSpace({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YrionTheme.spaceDeep, // Utilisation de notre constante de fond
      body: SafeArea(
        child: child, // Ton code de page s'affichera ici en toute sécurité
      ),
    );
  }
}