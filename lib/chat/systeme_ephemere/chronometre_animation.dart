import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🎨 **MOTEUR VISUEL : LE FLUX DE DISPARITION HOLOGRAPHIQUE YO**
class ChronometreAnimation extends StatelessWidget {
  final int dureeTotaleSecondes;
  final VoidCallback onTempsEcoule;

  const ChronometreAnimation({
    super.key,
    required this.dureeTotaleSecondes,
    required this.onTempsEcoule,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: Duration(seconds: dureeTotaleSecondes),
      onEnd: onTempsEcoule,
      builder: (context, value, child) {
        return SizedBox(
          width: 14, // Légèrement plus petit pour s'aligner parfaitement à gauche du texte
          height: 14,
          child: CustomPaint(
            painter: _UltimateTimerPainter(progression: value),
          ),
        );
      },
    );
  }
}

class _UltimateTimerPainter extends CustomPainter {
  final double progression;
  _UltimateTimerPainter({required this.progression});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintFond = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, paintFond);

    final gradientYo = SweepGradient(
      colors: const [
        Color(0xFF00D2FF),
        Color(0xFFE000FF),
        Color(0xFFFF007F),
        Color(0xFF00D2FF),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final paintArc = Paint()
      ..shader = gradientYo.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    double sweepAngle = 2 * math.pi * progression;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paintArc,
    );
  }

  @override
  bool shouldRepaint(_UltimateTimerPainter oldDelegate) {
    return oldDelegate.progression != progression;
  }
}

//ce fichier est le pinceaux grafique neon haute fluide qui s'aucupe de faire fondre le crecle 
// animation du chrono qui va le faire fondre terminer en fonction du chrono que l'utilisateur a choisis