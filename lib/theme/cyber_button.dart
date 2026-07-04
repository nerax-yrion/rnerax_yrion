import 'package:flutter/material.dart';
import '../theme/yrion_theme.dart';

class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isMagenta;

  const CyberButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isMagenta = true, // Par défaut le liseré sera magenta, sinon cyan
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: YrionTheme.cardBackground,
          borderRadius: BorderRadius.circular(24), // Forme capsule arrondie
          border: Border.all(
            color: isMagenta 
                ? YrionTheme.magentaNeon.withOpacity(0.6) 
                : YrionTheme.cyanNeon.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isMagenta ? YrionTheme.magentaNeon : YrionTheme.cyanNeon).withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ce fichier est le mole de se boutton