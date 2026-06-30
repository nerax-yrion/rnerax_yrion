import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart'; // 👈 On importe ton fichier thème ici !

class CyberTitleConnexion extends StatelessWidget {
  const CyberTitleConnexion({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      // 🎨 Plus aucun code couleur en dur ici, on utilise ton catalogue !
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          YrionTheme.cyanNeon,    // 👈 Utilise ton Cyan officiel
          YrionTheme.borderNeon,  // 👈 Utilise ton Bleu/Violet de transition
          YrionTheme.magentaNeon, // 👈 Utilise ton Rose Magenta officiel
        ],
      ).createShader(bounds),
      child: const Text(
        'connexion',
        style: TextStyle(
          fontFamily: 'AlexBrush', 
          fontSize: 52, 
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}