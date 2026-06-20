import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🎨 **MOTEUR VISUEL CYBER : L'ONDE EN RELIEF HOLOGRAPHIQUE YO**
/// Calqué fidèlement sur le design 3D néon exclusif de ton application.
class CapsuleAudioDesign extends StatelessWidget {
  final double progressionLecture; // Entre 0.0 et 1.0
  final bool estEnTrainDeLire;
  final VoidCallback onBoutonActionPressed;
  final VoidCallback? onAnnulerEnvoi; // Si fourni, affiche la poubelle d'annulation
  final String formatChrono;

  const CapsuleAudioDesign({
    super.key,
    required this.progressionLecture,
    required this.estEnTrainDeLire,
    required this.onBoutonActionPressed,
    required this.formatChrono,
    this.onAnnulerEnvoi,
  });

  @override
  Widget build(BuildContext context) {
    // Ta charte graphique Néon Espace Luminescent
    const colorBleuCyan = Color(0xFF00D2FF);
    const colorRoseFluo = Color(0xFFFF007F);
    const colorViolet = Color(0xFFE000FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0716), // Noir Profond Espace
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorBleuCyan.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(-2, 2),
          ),
          BoxShadow(
            color: colorRoseFluo.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(2, -2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🕹️ LE BOUTON CYBER-DÉGRADÉ YO
          GestureDetector(
            onTap: onBoutonActionPressed,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colorBleuCyan, colorViolet, colorRoseFluo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                estEnTrainDeLire ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // 📊 DEGRADÉ D'ONDES TRIPHONIQUES EN RELIEF (Style Image Éco)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32, // Plus haut pour donner cet effet de relief 3D
                  child: CustomPaint(
                    size: const Size(double.infinity, 32),
                    painter: _OndeReliefProPainter(
                      progression: progressionLecture,
                      cyan: colorBleuCyan,
                      rose: colorRoseFluo,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatChrono,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // 🗑️ LA PETITE POUBELLE D'ANNULATION EXCLUSIVE YO
          if (onAnnulerEnvoi != null) ...[
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFFF3B30), size: 24),
              onPressed: onAnnulerEnvoi,
              tooltip: "Annuler l'enregistrement",
            ),
          ],
        ],
      ),
    );
  }
}

/// 🖌️ LE PINCEAU DE SCULPTURE 3D : REPRODUIT TON IMAGE AVEC DES FINS DÉGRADÉS COULISSANTS
class _OndeReliefProPainter extends CustomPainter {
  final double progression;
  final Color cyan;
  final Color rose;

  _OndeReliefProPainter({required this.progression, required this.cyan, required this.rose});

  @override
  void paint(Canvas canvas, Size size) {
    final double milieuY = size.height / 2;
    
    // Courbe d'amplitude calquée exactement sur la forme de l'onde de ton image
    final List<double> amplitudesFideles = [
      0.15, 0.25, 0.40, 0.30, 0.55, 0.75, 0.95, 0.80, 
      0.65, 0.85, 1.00, 0.70, 0.50, 0.35, 0.20, 0.10
    ];

    double largeurBarre = 4.0; // Barres épaisses relief
    double espacement = 3.5;
    int nombreBarres = (size.width / (largeurBarre + espacement)).floor();
    int totalAmplitudes = amplitudesFideles.length;

    for (int i = 0; i < nombreBarres; i++) {
      double x = i * (largeurBarre + espacement);
      double ratioPosition = i / nombreBarres;

      // Définition de la couleur de la barre en fonction du dégradé de progression
      final Paint paintBarre = Paint()..style = PaintingStyle.fill;

      if (ratioPosition <= progression) {
        // Mélange parfait Cyan/Rose fluorescent au point d'avancement
        paintBarre.color = Color.lerp(cyan, rose, ratioPosition)!;
      } else {
        // Mode éteint translucide d'arrière-plan cyber
        paintBarre.color = Colors.white.withOpacity(0.12);
      }

      // Sélection de l'amplitude correspondante à la zone
      double facteurAmplitude = amplitudesFideles[((i / nombreBarres) * totalAmplitudes).floor().clamp(0, totalAmplitudes - 1)];
      
      // Ajout d'une légère oscillation mathématique pour donner vie à la 3D
      double hauteurBarre = size.height * math.max(0.01, facteurAmplitude);

      // Dessin des capsules arrondies montantes et descendantes
      final rectBarre = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, milieuY - (hauteurBarre / 2), largeurBarre, hauteurBarre),
        Radius.circular(largeurBarre / 2),
      );

      // Effet d'ombrage inférieur pour simuler le relief 3D de ton boîtier métallique
      if (ratioPosition <= progression) {
        canvas.drawRRect(
          rectBarre, 
          Paint()
            ..color = paintBarre.color.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        );
      }

      canvas.drawRRect(rectBarre, paintBarre);
    }
  }

  @override
  bool shouldRepaint(_OndeReliefProPainter oldDelegate) {
    return oldDelegate.progression != progression;
  }
}