// lib/screens/selection_langue_screen.dart
import 'package:flutter/material.dart';
import '../theme/image_du_fond/background_space.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'package:nerax_yrion/partie_lange/widgets/recherche_langue.dart'; 
import 'package:nerax_yrion/partie_lange/widgets/deroulement_langue.dart'; 
import 'package:nerax_yrion/partie_lange/data/global_languages_hub.dart';

class SelectionLangueScreen extends StatefulWidget {
  const SelectionLangueScreen({super.key});

  @override
  State<SelectionLangueScreen> createState() => _SelectionLangueScreenState();
}

class _SelectionLangueScreenState extends State<SelectionLangueScreen> {
  final TextEditingController _controleurRecherche = TextEditingController();
  String _langueActive = 'fr';
  String _saisieRecherche = '';

  @override
  void dispose() {
    _controleurRecherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundSpace(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const CyberHeader(title: "REGIONS", showBackButton: true),
              
              // 🔍 Ton composant de recherche en Français
              RechercheLangue(
                controller: _controleurRecherche,
                onChanged: (val) {
                  setState(() {
                    _saisieRecherche = val.toLowerCase();
                  });
                },
              ),
              
              const SizedBox(height: 8),

              // 🗺️ Tes composants de déroulement en Français
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: GlobalLanguagesHub.regionalRegistry.keys.map((continent) {
                    final toutesLesLangues = GlobalLanguagesHub.regionalRegistry[continent]!;

                    // Filtrage des langues
                    final listFiltree = toutesLesLangues.where((l) {
                      return l['nom']!.toLowerCase().contains(_saisieRecherche);
                    }).toList();

                    if (_saisieRecherche.isNotEmpty && listFiltree.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return DeroulementLangue(
                      titreContinent: continent,
                      listeLangues: listFiltree,
                      codeLangueSelectionnee: _langueActive,
                      estOuvertDoffice: _saisieRecherche.isNotEmpty, // S'ouvre tout seul si on cherche
                      auChoixLangue: (code) {
                        setState(() {
                          _langueActive = code;
                        });
                        print("[YRION ENGINE] Langue sélectionnée : $code");
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}