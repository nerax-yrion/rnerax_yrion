import 'package:flutter/material.dart';
import 'package:nerax_yrion/partie connexion et inscription/inscription/inscription.dart'; // Ajuste l'import selon ton dossier réel
import 'package:nerax_yrion/partie connexion et inscription/connexion/connexion.dart'; // Ajuste l'import selon ton dossier réel

class YrionChoixPage extends StatelessWidget {
  const YrionChoixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Blanc pur comme demandé
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                /// 🪐 LOGO PRINCIPAL (Reprend le style épuré de tes maquettes)
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9D4EDD).withOpacity(0.15),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/image_utile.png", // Ton logo YO néon
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 50),

                /// ✍️ MESSAGE DE BIENVENUE
                const Text(
                  "Bienvenue sur Yrion",
                  style: TextStyle(
                    fontFamily: 'Cursive', // Applique ta police cursive si configurée, sinon le style par défaut s'adaptera
                    color: Color(0xFF0F0F1A),
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const Spacer(),

                /// 🟦 BOUTON DEGRADÉ : SE CONNECTER
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30), // Bords très arrondis comme sur ta photo
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4D8), Color(0xFF0077B6)], // Dégradé Bleu/Cyan technologique
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B4D8).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // ➡️ Navigation vers ta page ConnexionPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConnexionPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "SE CONNECTER",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🟪 BOUTON DEGRADÉ : S'INSCRIRE
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9D4EDD), Color(0xFF7B2CBF)], // Dégradé Violet royal
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9D4EDD).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // ➡️ Navigation vers ta page InscriptionPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InscriptionPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "S'INSCRIRE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}