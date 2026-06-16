import 'package:flutter/material.dart';
import '../partie splite/accueil.dart'; 
import '../profil/profil.dart';
import 'package:nerax_yrion/parametre/parametre.dart';
import 'package:nerax_yrion/partie splite/create_split_page.dart'; 
import 'package:nerax_yrion/profil/profil_data.dart'; // 🧬 Liaison avec ton cache centralisé Rust/Neon
import 'package:nerax_yrion/theme/yrion_theme.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  // Intégration complète de tes pages officielles
  final List<Widget> _pages = [
    const AccueilPage(),
    const ProfilPage(),
    const ParametresPage(),
  ];

  void _openCreateSplitOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7), 
      builder: (context) => const CreateSplitPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070512),
      body: Stack(
        children: [
          /// 1. LE CONTENU (100% Plein Écran, Indexé sans lag)
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          /// 2. LE BOUTON DÉCLENCHEUR FLOTTANT YRION (Style Électrique Centré)
          Positioned(
            bottom: 24, 
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: GestureDetector(
              onTap: _openCreateSplitOverlay,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [YrionTheme.cyanNeon, Color(0xFF9D00FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9D00FF).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),

      /// 3. LA BARRE DE NAVIGATION STYLE PREMIUM STARTUP
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF070512),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 🏠 ONGLET : ACCUEIL (Index 0)
                _buildNavItem(
                  index: 0,
                  icon: Icons.grid_view_rounded,
                  activeIcon: Icons.grid_view_rounded,
                ),

                // 👤 ONGLET : PROFIL UTILISATEUR DYNAMIQUE STYLE INSTA (Index 1)
                _buildProfileNavItem(index: 1),

                // 🎯 ZONE MORTE VISUELLE POUR ACCUEILLIR LE BOUTON FLOTTANT CENTRÉ "+"
                const SizedBox(width: 56),

                // ⚙️ ONGLET : PARAMÈTRES (Index 2)
                _buildNavItem(
                  index: 2,
                  icon: Icons.settings_rounded,
                  activeIcon: Icons.settings_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🛠️ GÉNÉRATEUR D'ONGLET STANDARD RE-DESIGNÉ
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: 26,
          color: isSelected ? const Color(0xFF00D2FF) : Colors.white38,
        ),
      ),
    );
  }

  /// 👤 GÉNÉRATEUR DE L'AVATAR DYNAMIQUE INSTAGRAM-LEVEL
  Widget _buildProfileNavItem({required int index}) {
    final bool isSelected = _currentIndex == index;
    
    // Détermination de la source d'image prioritaire du cache
    ImageProvider? imagePrioritaire;
    if (ProfilData.avatarFichierLocal != null) {
      imagePrioritaire = FileImage(ProfilData.avatarFichierLocal!);
    } else if (ProfilData.urlAvatarDistant != null && ProfilData.urlAvatarDistant!.isNotEmpty) {
      imagePrioritaire = NetworkImage(ProfilData.urlAvatarDistant!);
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(2), // Épaisseur de la bordure de sélection
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF00D2FF) // Éclat Bleu Néon si sélectionné
                    : Colors.transparent,     // Invisible si non sélectionné
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 14, // Taille calibrée sur les spécifications d'UI d'Instagram
              backgroundColor: YrionTheme.cardBackground,
              backgroundImage: imagePrioritaire,
              child: imagePrioritaire == null
                  ? Text(
                      ProfilData.obtenirInitiale(),
                      style: const TextStyle(
                        color: YrionTheme.cyanNeon,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}