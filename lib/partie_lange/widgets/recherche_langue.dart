// lib/widgets/recherche_langue.dart
import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';

class RechercheLangue extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController controller;

  const RechercheLangue({
    super.key,
    required this.onChanged,
    required this.controller,
    this.hintText = "Rechercher une langue...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: YrionTheme.cyanNeon.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: YrionTheme.cyanNeon, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.5), size: 20),
                )
              : null,
          filled: true,
          fillColor: YrionTheme.cardBackground.withOpacity(0.65),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: YrionTheme.cyanNeon, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// se fichier va permetre de chercher des utilisateur