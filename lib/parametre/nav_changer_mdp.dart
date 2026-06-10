import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';

class NavChangerMdp extends StatelessWidget {
  const NavChangerMdp({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("METTRE À JOUR LA CLÉ D'ACCÈS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        TextField(obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Ancien mot de passe', labelStyle: TextStyle(color: YrionTheme.textMuted))),
        TextField(obscureText: true, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Nouveau mot de passe', labelStyle: TextStyle(color: YrionTheme.textMuted))),
      ],
    );
  }
}

// petite navigation qui permete de modifier les profile