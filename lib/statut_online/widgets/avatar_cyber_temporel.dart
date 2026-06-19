import 'package:flutter/material.dart';
import '../yrion_flux_moteur.dart';
import 'package:nerax_yrion/message/chat_user_model.dart';
import 'package:flutter/cupertino.dart';

class AvatarCyberTemporel extends StatelessWidget {
  final ChatUser user;
  final double radius;

  const AvatarCyberTemporel({
    super.key,
    required this.user,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Règle d'or : On planifie la synchronisation juste après le rendu pour ne pas bloquer le thread UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      YrionFluxMoteur.synchroniserMoteur();
    });

    return RepaintBoundary( // 🏎️ Isole ce widget au niveau du GPU. Les animations du badge ne font plus re-dessiner le reste de l'écran !
      child: SizedBox(
        width: (radius * 2) + 4,
        height: (radius * 2) + 4,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Permet au badge cyber de dépasser proprement si nécessaire
          children: [
            
            // 📸 ÉTAGE 1 : L'avatar principal ultra-sécurisé
            CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white.withOpacity(0.04),
              child: ClipOval(
                child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? Image.network(
                        user.avatarUrl!,
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.cover,
                        // 🛡️ Blindage contre les pannes réseau ou fausses URLs
                        errorBuilder: (context, error, stackTrace) => _buildInitiales(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.white.withOpacity(0.02),
                            child: const CupertinoActivityIndicator(radius: 8, color: Colors.white24),
                          );
                        },
                      )
                    : _buildInitiales(),
              ),
            ),

            // 🛡️ ÉTAGE 2 : Le Badge Temporel Cyber-Réactif Unifié
            if (user.enLigne)
              Positioned(
                bottom: -1,
                right: -1,
                child: _buildBadgeCyber(),
              ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Générateur d'initiales stylisées en cas d'absence d'avatar
  Widget _buildInitiales() {
    return Center(
      child: Text(
        user.pseudo.isNotEmpty ? user.pseudo[0].toUpperCase() : 'Y',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w900,
          fontSize: radius * 0.75,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  /// ⚡ Le Badge intelligent synchrone (Zéro imbrication de Builders)
  Widget _buildBadgeCyber() {
    // On écoute le flux de couleur en priorité
    return ValueListenableBuilder<Color>(
      valueListenable: YrionFluxMoteur.fluxLueur,
      builder: (context, couleurNeon, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF070512), // Fond officiel Yrion
            shape: BoxShape.circle,
            border: Border.all(
              color: couleurNeon.withOpacity(0.65), 
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: couleurNeon.withOpacity(0.25),
                blurRadius: 6,
                spreadRadius: 0.2,
              ),
            ],
          ),
          // On écoute l'emoji de manière isolée pour éviter de re-calculer la BoxDécoration complète
          child: ValueListenableBuilder<String>(
            valueListenable: YrionFluxMoteur.fluxEmoji,
            builder: (context, emoji, _) {
              return Text(
                emoji,
                style: const TextStyle(
                  fontSize: 9.5, 
                  height: 1.0,
                  fontFamily: 'Apple Color Emoji', // Force un rendu emoji premium fluide
                ),
              );
            },
          ),
        );
      },
    );
  }
}