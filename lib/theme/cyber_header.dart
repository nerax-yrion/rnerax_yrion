import 'package:flutter/material.dart';

class CyberTitleConnexion extends StatelessWidget {
  const CyberTitleConnexion({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      // 🎨 Configuration du dégradé ajusté (Cyan -> Bleu Électrique -> Rose Magenta)
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF00B4DB), // Cyan lumineux (début de "connexion")
          Color(0xFF5B62E6), // Bleu-violet de transition
          Color(0xFFD946EF), // Rose / Magenta vif (fin de "connexion")
        ],
      ).createShader(bounds),
      child: const Text(
        'connexion',
        style: TextStyle(
          fontFamily: 'AlexBrush', 
          fontSize: 52, // Un poil plus grand pour bien apprécier le dégradé
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}