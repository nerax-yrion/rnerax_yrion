import 'package:flutter/material.dart';

// Importation de ton fichier de design pure
import 'orbit_navbar_view.dart';

// Importations de tes pages officielles
import '../partie splite/accueil.dart'; // Gardé tel quel selon ton arborescence

import '../profil/profil.dart';
import 'package:nerax_yrion/parametre/parametre.dart';
// L'écran de création que l'on va coder juste après
import 'package:nerax_yrion/partie splite/create_split_page.dart'; 

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  // Liste ordonnée de tes écrans inclusifs du système YRION
  final List<Widget> _pages = [
    const AccueilPage(),
    const ProfilPage(),
    const ParametresPage(),
  ];

  // Fonction pour ouvrir l'interface de création en Overlay (par-dessus le reste)
  void _openCreateSplitOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateSplitPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070512), // Fond cosmique sombre unifié
      body: SafeArea(
        child: Stack(
          children: [
            /// 1. LE CONTENU DE LA PAGE ACTUELLE
            // IndexedStack évite de reconstruire les pages à chaque changement d'onglet
            Padding(
              padding: const EdgeInsets.only(left: 110),
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),

            /// 2. L'INJECTION DU DESIGN DE TA BARRE ORBITALE
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 120, 
              child: OrbitNavbarView(
                currentIndex: _currentIndex,
                onTabSelected: (index) {
                  // Si ton OrbitNavbarView possède un index spécifique pour le "+" du Split,
                  // tu le déclenches ici, sinon gère-le via les onglets classiques.
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),

            /// 3. LE BOUTON DÉCLENCHEUR FLOTTANT YRION (Optionnel si pas intégré dans ton OrbitNavbarView)
            Positioned(
              bottom: 25,
              right: 25,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF9D00FF), // Violet Néon YRION
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                onPressed: () {
                  _openCreateSplitOverlay();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}