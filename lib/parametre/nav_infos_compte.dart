import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'parametres_widgets.dart';

class NavInfosComptePage extends StatelessWidget {
  const NavInfosComptePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YrionTheme.spaceDeep,
      body: SafeArea(
        child: Column(
          children: [
            /// En-tête officiel avec bouton retour actif
            const CyberHeader(title: "MATRICE IDENTITÉ", showBackButton: true),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParametresWidgets.buildSectionDivider("DONNÉES DU FLUX COMPTE"),
                    const SizedBox(height: 12),
                    
                    ParametresWidgets.buildInfoContainer([
                      ParametresWidgets.buildInfoRow("Matrice Email", "alex.dev@yrion.io"),
                      ParametresWidgets.buildInfoRow("Liaison Réseau", "+261 34 00 000 00"),
                      ParametresWidgets.buildInfoRow("Clef Privée ID", "YO-9942-X-2026"),
                      ParametresWidgets.buildInfoRow("Statut Vérification", "Validé sur l'orbite", isVerified: true),
                    ]),
                    
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Ces identifiants de session sont générés de manière chiffrée par le noyau de sécurité.",
                        style: TextStyle(color: YrionTheme.textMuted, fontSize: 11),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}