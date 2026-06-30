import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'yrion_auth_storage.dart';
// 🎨 IMPORTATION DU PEINTRE CYBER-TEMPOREL D'YRION
import '../theme/image_du_fond/background_space.dart'; 

class YrionSplashScreen extends StatefulWidget {
  const YrionSplashScreen({super.key});

  @override
  State<YrionSplashScreen> createState() => _YrionSplashScreenState();
}

class _YrionSplashScreenState extends State<YrionSplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _orbiteController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Animation de respiration (pulsation douce) pour ton logo YO
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // 2. Animation de gravitation orbitale pour la touche spatiale
    _orbiteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // 3. Lancement du compte à rebours de connexion automatique
    _demarrerChronometreQuantique();
  }

  Future<void> _demarrerChronometreQuantique() async {
    // ⏱️ EXACTEMENT 2.5 SECONDES (2500 millisecondes)
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // Vérification du Token dans ton dossier tocken
    String? tokenValide = await YrionAuthStorage.lireToken();

    if (!mounted) return;

    if (tokenValide != null && tokenValide.isNotEmpty) {
      print("[YRION CORE] Session active trouvée ! Accès direct au Chat.");
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
    } else {
      print("[YRION CORE] Redirection vers l'écran d'identification.");
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ConnexionScreen()));
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _orbiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌌 MAGIE : On enveloppe la Stack spatiale directement dans ton BackgroundSpace
    return BackgroundSpace(
      child: Stack(
        alignment: Alignment.center,
        children: [
          
          // 🛰️ ACCOMPAGNEMENT 1 : Lignes d'orbites fines (visibles discrètement en surimpression)
          Positioned(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF9D4EDD).withOpacity(0.08), width: 1),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.06), width: 1.2),
              ),
            ),
          ),

          // 🔮 ACCOMPAGNEMENT 2 : Halo lumineux néon diffusé reprenant les couleurs de ton logo YO
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF9D4EDD).withOpacity(0.12), // Reflet violet
                  const Color(0xFF00B4D8).withOpacity(0.08), // Reflet bleu électrique
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 👨‍🚀 ACCOMPAGNEMENT 3 : L'astronaute/fusée en orbite calculée autour de YO
          AnimatedBuilder(
            animation: _orbiteController,
            builder: (context, child) {
              double angle = _orbiteController.value * 2 * math.pi;
              double rayonOrbite = 135.0; // Rayon parfait pour tourner autour de l'image
              double x = rayonOrbite * math.cos(angle);
              double y = rayonOrbite * math.sin(angle);

              return Transform.translate(
                offset: Offset(x, y),
                child: Transform.rotate(
                  angle: angle + (math.pi / 2), // Aligne l'icône dans le sens du vol
                  child: const Icon(
                    Icons.rocket_launch_outlined, 
                    color: Color(0xFF9D4EDD), // Teinte néon harmonisée avec ton écosystème
                    size: 26,
                  ),
                ),
              );
            },
          ),

          // 🛸 Ton Logo original "YO" au centre avec sa pulsation quantique
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 185,
              height: 185,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9D4EDD).withOpacity(0.08),
                    blurRadius: 25,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/image_utile.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ✍️ Signature textuelle Yrion épurée en bas de l'écran
          Positioned(
            bottom: 70,
            child: Column(
              children: [
                const Text(
                  "YRION",
                  style: TextStyle(
                    color: Colors.white, // Blanc pur obligatoire pour trancher proprement sur le fond Nuit !
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 9,
                    shadows: [
                      Shadow(
                        color: Colors.black38, // Légère ombre protectrice au cas où le fond est très clair (Matin/Midi)
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Petite barre technologique dégradée cyan/violet
                Container(
                  width: 90,
                  height: 2.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4D8), Color(0xFF9D4EDD)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}