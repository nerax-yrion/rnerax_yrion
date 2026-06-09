import 'package:flutter/material.dart';

// Tes pages officielles
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

  final List<Widget> _pages = [
    const AccueilPage(),
    const MessagePage(), 
    const ProfilPage(),
    const ParametresPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070512), 
      body: SafeArea(
        child: Stack(
          children: [
            /// 1. LE CONTENU (Espace pour la navigation courbe)
            Padding(
              padding: const EdgeInsets.only(left: 100),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _pages[_currentIndex],
              ),
            ),

            /// 2. LA BARRE DE NAVIGATION VERTICALE ET INCURVÉE (ARC DE CERCLE)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 110, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  // 🏠 Accueil (Haut de l'arc)
                  _buildVerticalOrbitIcon(
                    index: 0,
                    icon: Icons.grid_view_rounded,
                    curveOffset: 15.0, // Indentation de départ
                  ),
                  const SizedBox(height: 40),

                  // 💬 Message (Apex de l'arc - le plus à DROITE)
                  _buildVerticalOrbitIcon(
                    index: 1,
                    icon: Icons.chat_bubble_rounded,
                    curveOffset: 45.0, // Pointe de la courbe
                  ),
                  const SizedBox(height: 40),

                  // 👤 Profil (Retour vers la gauche)
                  _buildVerticalOrbitIcon(
                    index: 2,
                    icon: Icons.person_rounded,
                    curveOffset: 30.0, // Milieu du retour
                  ),
                  const SizedBox(height: 40),

                  // ⚙️ Paramètres (Bas de l'arc - le plus à GAUCHE)
                  _buildVerticalOrbitIcon(
                    index: 3,
                    icon: Icons.settings_rounded,
                    curveOffset: 10.0, // Fin de la courbe
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalOrbitIcon({
    required int index,
    required IconData icon,
    required double curveOffset,
  }) {
    final bool isSelected = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutSine,
      margin: EdgeInsets.only(left: curveOffset),
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.white : const Color(0xFF1C1C2E),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(-3, 0),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF00D6).withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(3, 0),
                    ),
                  ]
                : [],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              if (isSelected) {
                return const LinearGradient(
                  colors: [Color(0xFF00F0FF), Color(0xFFFF00D6)],
                ).createShader(bounds);
              }
              return const LinearGradient(
                colors: [Color(0xFF5D598C), Color(0xFF5D598C)],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Icon(icon, size: 26),
          ),
        ),
      ),
    );
  }
}