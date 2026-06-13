import 'package:flutter/material.dart';
import '../partie splite/accueil.dart'; 
import '../profil/profil.dart';
import 'package:nerax_yrion/parametre/parametre.dart';
import 'package:nerax_yrion/partie splite/create_split_page.dart'; 

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  // Les 3 pages officielles d'YRION
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
      barrierColor: Colors.black.withOpacity(0.7), // Assombrit le fond pour le focus
      builder: (context) => const CreateSplitPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070512),
      body: Stack(
        children: [
          /// 1. LE CONTENU (100% Plein Écran, Zéro décalage)
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          /// 2. LE BOUTON DÉCLENCHEUR FLOTTANT YRION (Style Électrique Centré)
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: GestureDetector(
              onTap: _openCreateSplitOverlay,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF9D00FF),
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

      /// 3. LA BARRE DE NAVIGATION NATIVE BASSE
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex > 1 ? _currentIndex + 1 : _currentIndex,
          onTap: (index) {
            if (index == 1) return; // Zone morte réservée au bouton central "+"
            setState(() {
              _currentIndex = index > 1 ? index - 1 : index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF070512),
          selectedItemColor: const Color(0xFF00D2FF), // Éclat Bleu Néon
          unselectedItemColor: Colors.white38,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded, size: 26), label: 'Accueil'),
            BottomNavigationBarItem(icon: SizedBox(width: 40), label: ''), // Espace pour le bouton +
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 28), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}