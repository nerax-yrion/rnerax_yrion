import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';

class NavListeBloquesPage extends StatelessWidget {
  const NavListeBloquesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: YrionTheme.spaceDeep,
      body: SafeArea(
        child: Column(
          children: [
            CyberHeader(title: "COMPTES VERROUILLÉS", showBackButton: true),
            Expanded(
              child: Center(
                child: Text(
                  "Aucun signal parasite bloqué pour le moment.", 
                  style: TextStyle(color: YrionTheme.textMuted, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}