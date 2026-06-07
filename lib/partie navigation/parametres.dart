import 'package:flutter/material.dart';

class ParametresPage extends StatelessWidget {
  const ParametresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text(
          "Paramètres",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            settingTile(
              Icons.person,
              "Compte",
            ),

            settingTile(
              Icons.lock,
              "Confidentialité",
            ),

            settingTile(
              Icons.logout,
              "Déconnexion",
            ),
          ],
        ),
      ),
    );
  }

  Widget settingTile(
    IconData icon,
    String title,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.cyan,
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
      ),
    );
  }
}