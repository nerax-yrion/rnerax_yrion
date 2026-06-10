import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';

class CyberHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const CyberHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context), // Retour arrière sécurisé sans crash
            ),
          Expanded(
            child: Text(
              title,
              textAlign: showBackButton ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                color: YrionTheme.cyanNeon, // Mis à jour avec ta couleur néon officielle !
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          // Petit espacement pour équilibrer le titre si le bouton retour est présent
          if (showBackButton) const SizedBox(width: 48),
        ],
      ),
    );
  }
}