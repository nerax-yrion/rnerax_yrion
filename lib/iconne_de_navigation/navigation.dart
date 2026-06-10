import 'package:flutter/material.dart';

// Importation de ton fichier de design pure
import 'orbit_navbar_view.dart';

// Importations de tes pages officielles
import '../accueil.dart';
import '../message.dart'; 
import '../profil.dart';
import '../parametres.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  // Liste ordonnée de tes écrans
  final List<Widget> _pages = [
    const AccueilPage(),
    const MessagePage(), 
    const ProfilPage(),
    const ParametresPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070512), // Fond cosmique sombre unifié
      body: SafeArea(
        child: Stack(
          children: [
            /// 1. LE CONTENU DE LA PAGE ACTUELLE
            // Un padding à gauche de 110px permet d'éviter les collisions avec l'arc des icônes
            Padding(
              padding: const EdgeInsets.only(left: 110),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: _pages[_currentIndex],
              ),
            ),

            /// 2. L'INJECTION DU DESIGN DE TA BARRE ORBITALE
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 120, // Légèrement élargi pour accueillir l'effet d'échelle de l'animation
              child: OrbitNavbarView(
                currentIndex: _currentIndex,
                onTabSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}