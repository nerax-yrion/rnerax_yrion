import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';

class ParametresWidgets {
  
  /// 🌌 Séparateur de section avec ligne néon estompée
  static Widget buildSectionDivider(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: YrionTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1, 
            color: YrionTheme.borderNeon.withOpacity(0.3)
          ),
        ),
      ],
    );
  }

  /// ⚙️ Conteneur sombre pour regrouper les lignes d'informations ou de boutons
  static Widget buildInfoContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: YrionTheme.cardBackground.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: YrionTheme.borderNeon.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  /// 🛰️ Ligne d'affichage des données (Email, téléphone, clé d'accès)
  static Widget buildInfoRow(String label, String value, {bool isVerified = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: YrionTheme.borderNeon.withOpacity(0.15))
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: const TextStyle(color: YrionTheme.textLight, fontSize: 13)
          ),
          Row(
            children: [
              if (isVerified) ...[
                const Icon(Icons.verified_user_rounded, color: YrionTheme.cyanNeon, size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: TextStyle(
                  color: isVerified ? YrionTheme.cyanNeon : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🎛️ Ligne de menu cliquable pour ouvrir les navigations (Mots de passe, Bloqués, etc.)
  static Widget buildMenuRow(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: YrionTheme.cyanNeon, size: 18),
      title: Text(
        title, 
        style: const TextStyle(color: Colors.white, fontSize: 13)
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded, 
        color: YrionTheme.textMuted, 
        size: 12
      ),
      onTap: onTap,
    );
  }
}