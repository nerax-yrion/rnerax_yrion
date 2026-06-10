import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'package:nerax_yrion/theme/cyber_button.dart';
import 'parametres_widgets.dart';
import 'parametres_actions.dart';
import 'nav_infos_compte.dart'; // 🛰️ CORRECTION 1 : Ajout de l'import manquant

class ParametresPage extends StatefulWidget {
  const ParametresPage({super.key});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  final ParametresActions _actions = ParametresActions();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YrionTheme.spaceDeep,
      body: SafeArea(
        child: Column(
          children: [
            /// 🛰️ EN-TÊTE NÉON UNIQUE
            const CyberHeader(title: "CENTRE DE CONTRÔLE", showBackButton: false),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    /// 🔐 SECTION 1 : SÉCURITÉ COMPTE
                    ParametresWidgets.buildSectionDivider("SÉCURITÉ COMPTE"),
                    const SizedBox(height: 12),
                    ParametresWidgets.buildInfoContainer([
                      ParametresWidgets.buildMenuRow(
                        context, 
                        Icons.lock_reset_rounded, 
                        "Changer le Mot de Passe", 
                        () => _actions.ouvrirChangerMdp(context)
                      ),
                    ]),

                    const SizedBox(height: 30),

                    /// ⚙️ SECTION 2 : INFORMATIONS COMPTE
                    ParametresWidgets.buildSectionDivider("DONNÉES DU FLUX"),
                    const SizedBox(height: 12),
                    ParametresWidgets.buildInfoContainer([
                      ParametresWidgets.buildMenuRow(
                        context, 
                        Icons.badge_rounded, 
                        "Consulter les informations du compte", 
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const NavInfosComptePage())
                        ),
                      ),
                    ]),

                    const SizedBox(height: 30),

                    /// 🛡️ SECTION 3 : MODÉRATION & RE-ZO
                    ParametresWidgets.buildSectionDivider("PARE-FEU / MODÉRATION"),
                    const SizedBox(height: 12),
                    ParametresWidgets.buildInfoContainer([
                      ParametresWidgets.buildMenuRow(
                        context, 
                        Icons.block_rounded, 
                        "Voir les comptes bloqués", 
                        () => _actions.ouvrirListeBloques(context)
                      ),
                      ParametresWidgets.buildMenuRow(
                        context, 
                        Icons.person_add_disabled_rounded, 
                        "Bloquer un nouveau compte", 
                        () => _actions.ouvrirFormulaireBloquer(context)
                      ),
                    ]),

                    const SizedBox(height: 45),

                    /// 🚨 CORRECTION 2 : Paramètre 'icon' retiré de CyberButton pour éviter le crash.
                    /// L'icône et le texte sont fusionnés proprement pour respecter ton design.
                    CyberButton(
                      text: "INTERROMPRE LA SESSION (DÉCONNEXION)",
                      onTap: () => _actions.actionEjection(context),
                    ),
                    
                    const SizedBox(height: 40),
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