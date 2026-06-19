import 'package:flutter/material.dart';

class GestionnaireTemps {
  
  /// 🌍 Récupère l'heure locale exacte de l'utilisateur en respectant son fuseau horaire
  static int get heureLocale => DateTime.now().toLocal().hour;

  /// ⏰ Détermine si c'est la nuit (entre 17h et 7h du matin) chez l'utilisateur
  static bool get estLaNuit {
    final int heure = heureLocale;
    return heure >= 17 || heure < 7;
  }

  /// ☀️/🌙 Renvoie l'emoji correspondant au statut temporel local
  static String get emojiStatut => estLaNuit ? "🌙" : "☀️";

  /// 🎨 Idée Yrion : Renvoie une couleur de lueur dynamique selon l'heure exacte
  /// Plus il est tard, plus l'indigo est profond. Plus il est midi, plus le jaune flashe.
  static Color get couleurLueur {
    if (estLaNuit) {
      return heureLocale >= 22 || heureLocale < 4 
          ? const Color(0xFF7000FF) // Violet néon profond (Minuit)
          : const Color(0xFF00E5FF); // Cyan néon (Début de soirée)
    } else {
      return heureLocale >= 11 && heureLocale <= 14
          ? const Color(0xFFFFD700) // Or pur (Plein soleil de midi)
          : const Color(0xFFFF9100); // Orange néon (Aube / Après-midi)
    }
  }

  /// 💬 Idée Yrion 2 : Génère un texte d'ambiance personnalisé pour le profil
  static String get texteAmbiance {
    final int heure = heureLocale;
    if (heure >= 5 && heure < 12) return "En mode matinal ⚡";
    if (heure >= 12 && heure < 17) return "Focus sur l'objectif 🎯";
    if (heure >= 17 && heure < 21) return "Détente chillout 🌌";
    return "Dans la matrice nocturne 💻";
  }
}