import 'package:flutter/material.dart';

// Tes pages officielles
import 'package:nerax_yrion/navigation%20acceuil/accueil.dart';
import 'package:nerax_yrion/navigation%20profil/partie%20navigation/message.dart'; 
import 'package:nerax_yrion/navigation profil/profil 1er plant/profil.dart';
import 'package:nerax_yrion/navigation%20profil/partie%20navigation/parametres.dart';

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
      backgroundColor: const Color(0xFF070512), // Fond d'espace sombre
      body: SafeArea(
        child: Stack(
          children: [
            /// 1. LE CONTENU DE LA PAGE SÉLECTIONNÉE
            // On laisse un espace à gauche de 100px pour ne pas chevaucher la courbe des icônes
            Padding(
              padding: const EdgeInsets.only(left: 100),
              child: Container(
                color: const Color(0xFF020205),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _pages[_currentIndex],
                ),
              ),
            ),

            /// 2. LA BARRE DE NAVIGATION VERTICALE ET INCURVÉE (Comme ta maquette !)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 110, // Zone assez large pour laisser les icônes faire l'arc de cercle
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // Permet le décalage horizontal
                children: [
                  // 🏠 Accueil (Légèrement décalé)
                  _buildVerticalOrbitIcon(
                    index: 0,
                    icon: Icons.grid_view_rounded,
                    curveOffset: 18.0, 
                  ),
                  const SizedBox(height: 35),

                  // 💬 Message (Au sommet de la courbe, le plus avancé vers la droite)
                  _buildVerticalOrbitIcon(
                    index: 1,
                    icon: Icons.chat_bubble_rounded,
                    curveOffset: 38.0, 
                  ),
                  const SizedBox(height: 35),

                  // 👤 Profil (Redescend sur la courbe vers la gauche)
                  _buildVerticalOrbitIcon(
                    index: 2,
                    icon: Icons.person_rounded,
                    curveOffset: 28.0, 
                  ),
                  const SizedBox(height: 35),

                  // ⚙️ Paramètres (Revenu aligné vers la gauche)
                  _buildVerticalOrbitIcon(
                    index: 3,
                    icon: Icons.settings_rounded,
                    curveOffset: 8.0, 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Conçoit l'icône avec sa position incurvée spécifique (curveOffset) et le style de ton logo
  Widget _buildVerticalOrbitIcon({
    required int index,
    required IconData icon,
    required double curveOffset, // Gère la courbure unique de ta maquette
  }) {
    final bool isSelected = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      // C'est ce paramètre magique qui crée l'arc de cercle vertical de ta maquette !
      margin: EdgeInsets.only(left: curveOffset),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Blanc brillant si sélectionné (comme le fond du logo YO)
            color: isSelected ? Colors.white : const Color(0xFF1C1C2E),
            boxShadow: isSelected
                ? [
                    // Effet Néon Cyan et Magenta de ton formulaire d'inscription
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(-2, 0),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF00D6).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(2, 0),
                    ),
                  ]
                : [],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              if (isSelected) {
                // Dégradé Cyan -> Magenta officiel de ton logo pour l'icône active
                return const LinearGradient(
                  colors: [Color(0xFF00F0FF), Color(0xFFFF00D6)],
                ).createShader(bounds);
              }
              // Couleur discrète pour les icônes inactives
              return const LinearGradient(
                colors: [Color(0xFF6C6A8B), Color(0xFF6C6A8B)],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Icon(
              icon,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}