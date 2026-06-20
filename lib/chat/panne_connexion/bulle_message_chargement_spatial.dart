import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'gestionnaire_signal_spatial.dart';

/// 🪐 **BULLE DE MESSAGE SIGNATURE : LE DIAGNOSTIC ORBITAL PRO**
/// Enveloppe protectrice cyber qui déploie une station en orbite 3D si le réseau lâche.
class BulleMessageChargementSpatial extends StatefulWidget {
  final Widget contenuMessage;
  final bool estMonMessage;
  final bool forcerChargementTest; // À passer à true pour tester en cours de dev

  const BulleMessageChargementSpatial({
    super.key,
    required this.contenuMessage,
    required this.estMonMessage,
    this.forcerChargementTest = false,
  });

  @override
  State<BulleMessageChargementSpatial> createState() => _BulleMessageChargementSpatialState();
}

class _BulleMessageChargementSpatialState extends State<BulleMessageChargementSpatial> with SingleTickerProviderStateMixin {
  late AnimationController _moteurAnimation;

  @override
  void initState() {
    super.initState();
    _moteurAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Vitesse de révolution orbitale
    )..repeat();
  }

  @override
  void dispose() {
    _moteurAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alignement = widget.estMonMessage ? Alignment.centerRight : Alignment.centerLeft;

    return StreamBuilder<EtatSignalOrbital>(
      stream: GestionnaireSignalSpatial().fluxSignal,
      initialData: EtatSignalOrbital.stable,
      builder: (context, snapshot) {
        final etatActuel = snapshot.data!;
        final bool doitAfficherStation = widget.forcerChargementTest || etatActuel != EtatSignalOrbital.stable;

        // Code couleur adaptatif (Cyan technologique ou Rouge alerte)
        final Color colorCyber = etatActuel == EtatSignalOrbital.perdu 
            ? const Color(0xFFFF3B30) 
            : const Color(0xFF00D2FF);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          alignment: alignement,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              
              // 🧱 ÉTAPE 1 : LE MESSAGE DE L'UTILISATEUR (LÉGÈREMENT ASSOMBRI SI ÇA RAME)
              Opacity(
                opacity: doitAfficherStation ? 0.70 : 1.0,
                child: widget.contenuMessage,
              ),

              // 🛰️ ÉTAPE 2 : LE SYSTÈME DE GRAVITATION DE LA STATION (SI SÉLECTIONNÉ)
              if (doitAfficherStation)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _moteurAnimation,
                    builder: (context, child) {
                      // Mathématiques de l'orbite elliptique
                      double angle = _moteurAnimation.value * math.pi * 2;
                      
                      // Déplacement horizontal de gauche à droite
                      double xOffset = math.cos(angle); 
                      // Déplacement vertical réduit pour simuler une ellipse écrasée (effet perspective)
                      double yOffset = math.sin(angle) * 0.3; 
                      
                      // Effet d'échelle 3D : la station grossit quand elle passe "devant" (yOffset > 0)
                      double echelle3D = 1.0 + (math.sin(angle) * 0.25);

                      return Transform.translate(
                        offset: Offset(xOffset * 80, yOffset * 20),
                        child: Transform.scale(
                          scale: echelle3D,
                          child: Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 📡 CORRECTION : On emballe le CustomPainter dans un CustomPaint Widget
                                  CustomPaint(
                                    painter: _OndeRadarImpulsion(
                                      progression: (_moteurAnimation.value * 2) % 1.0, 
                                      color: colorCyber,
                                    ),
                                  ),
                                  // 🛰️ Structure physique centrale de la station
                                  _NoyauStationSpatiale(
                                    color: colorCyber,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 🖌️ SHADER D'ONDE DE CHOC QUANTIQUE REPRODUISANT TON EFFET NÉON
class _OndeRadarImpulsion extends CustomPainter {
  final double progression;
  final Color color;
  _OndeRadarImpulsion({required this.progression, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = Offset(size.width / 2, size.height / 2);
    final Paint paintOnde = Paint()
      ..color = color.withOpacity((1.0 - progression).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    double rayonActuel = (size.width / 2) * progression * 1.5;
    canvas.drawCircle(centre, rayonActuel, paintOnde);
  }

  @override
  bool shouldRepaint(_OndeRadarImpulsion oldDelegate) => 
      oldDelegate.progression != progression || oldDelegate.color != color;
}

/// 🛰️ LA MICRO-STATION SATELLITE AVEC EFFET DE HALO CYBER
class _NoyauStationSpatiale extends StatelessWidget {
  final Color color;
  const _NoyauStationSpatiale({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.9),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF0A0716), // Cœur vide style trou noir
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}