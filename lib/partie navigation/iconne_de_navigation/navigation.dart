import 'package:flutter/material.dart';

import '../accueil.dart';
import '../profil.dart';
import '../parametres.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const AccueilPage(),
    const ProfilPage(),
    const ParametresPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      body: pages[currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151528),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.2),
              blurRadius: 20,
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          backgroundColor: const Color(0xFF151528),

          selectedItemColor: Colors.cyan,
          unselectedItemColor: Colors.white54,

          type: BottomNavigationBarType.fixed,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Accueil",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profil",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Paramètres",
            ),
          ],
        ),
      ),
    );
  }
}