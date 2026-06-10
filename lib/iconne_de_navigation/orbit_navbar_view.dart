import 'package:flutter/material.dart';

class OrbitNavbarView extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const OrbitNavbarView({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏠 Accueil (Haut de l'arc)
        _buildAnimatedOrbitIcon(
          index: 0,
          icon: Icons.grid_view_rounded,
          baseCurveOffset: 15.0,
        ),
        const SizedBox(height: 38),

        // 💬 Message (Apex de l'arc - le plus avancé à DROITE)
        _buildAnimatedOrbitIcon(
          index: 1,
          icon: Icons.chat_bubble_rounded,
          baseCurveOffset: 45.0,
        ),
        const SizedBox(height: 38),

        // 👤 Profil (Retour progressif vers la gauche)
        _buildAnimatedOrbitIcon(
          index: 2,
          icon: Icons.person_rounded,
          baseCurveOffset: 30.0,
        ),
        const SizedBox(height: 38),

        // ⚙️ Paramètres (Bas de l'arc - aligné à GAUCHE)
        _buildAnimatedOrbitIcon(
          index: 3,
          icon: Icons.settings_rounded,
          baseCurveOffset: 10.0,
        ),
      ],
    );
  }

  Widget _buildAnimatedOrbitIcon({
    required int index,
    required IconData icon,
    required double baseCurveOffset,
  }) {
    final bool isSelected = currentIndex == index;
    
    // Animation premium : Si l'icône est sélectionnée, elle se projette de 8px supplémentaires vers la droite
    final double dynamicOffset = isSelected ? baseCurveOffset + 8.0 : baseCurveOffset;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack, // Effet rebond ultra fluide au changement
      margin: EdgeInsets.only(left: dynamicOffset),
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.12 : 1.0, // L'icône active grossit subtilement
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.white : const Color(0xFF1C1C2E),
              boxShadow: isSelected
                  ? [
                      BoxShape.circle == BoxShape.circle
                          ? BoxShadow(
                              color: const Color(0xFF00F0FF).withOpacity(0.6),
                              blurRadius: 18,
                              offset: const Offset(-2, 0),
                            )
                          : const BoxShadow(),
                      BoxShadow(
                        color: const Color(0xFFFF00D6).withOpacity(0.6),
                        blurRadius: 18,
                        offset: const Offset(2, 0),
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
              child: Icon(icon, size: 25),
            ),
          ),
        ),
      ),
    );
  }
}