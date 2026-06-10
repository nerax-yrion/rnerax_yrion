import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'package:nerax_yrion/theme/cyber_button.dart';
import 'parametres_widgets.dart';
import 'parametres_actions.dart';

class ParametresPage extends StatefulWidget {
  const ParametresPage({super.key});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  final ParametresActions _actions = ParametresActions();
  String _compteActif = "@astronaute_du_974"; // Compte par défaut

  // Liste des profils pour le changement de compte rapide
  final List<Map<String, String>> _profilsLocaux = [
    {
      "username": "@astronaute_du_974",
      "nom": "Alexandre",
      "type": "Explorateur Principal",
      "avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150",
      "role": "Personnel",
    },
    {
      "username": "Sneakers_Shop_Tana",
      "nom": "Yrion Streetwear",
      "type": "Compte Magasin Vérifié",
      "avatar": "https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=150",
      "role": "Professionnel",
    },
  ];

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

                    /// 🔄 SECTION : CHANGEMENT DE COMPTE
                    ParametresWidgets.buildSectionDivider("COMMUTER DE DIMENSION (COMPTES)"),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _profilsLocaux.length,
                      itemBuilder: (context, index) {
                        final profil = _profilsLocaux[index];
                        return ParametresWidgets.buildCyberAccountTile(
                          profil: profil,
                          isActive: _compteActif == profil['username'],
                          onTap: () => setState(() => _compteActif = profil['username']!),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

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
                    ParametresWidgets.buildInfoContainer([ // 🛠️ CORRIGÉ : buildInfoContainer au lieu de withContainer
                      ParametresWidgets.buildMenuRow(
                        context, 
                        Icons.badge_rounded, 
                        "Consulter les informations du compte", 
                        () => _actions.ouvrirInfosCompte(context) // 🛠️ CORRIGÉ : Utilise l'action dédiée sans Navigator direct
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

                    /// 🚨 BOUTON DE DÉCONNEXION CYBERPUNK
                    CyberButton( // 🛠️ CORRIGÉ : Suppression du paramètre 'icon' qui provoquait l'erreur
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