import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';

class NavAjouterBlocage extends StatelessWidget {
  const NavAjouterBlocage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("BANNIR UN COMPTE DE VOTRE MATRIX", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: '@username_cible', 
            labelStyle: const TextStyle(color: YrionTheme.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: YrionTheme.magentaNeon.withOpacity(0.5))),
          ),
        ),
      ],
    );
  }
}

// petite navigation