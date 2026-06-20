import 'package:flutter/material.dart';
import '../../../profil/profil_data.dart';
// 🛠️ IMPORTATION CORRIGÉE : On va chercher ton fichier d'heure "chat_time.dart"
import 'chat_time.dart';

/// 🎨 **LE COMPOSANT BULLE DE MESSAGE**
/// Ce fichier s'occupe UNIQUE-MENT de dessiner la forme de la bulle,
/// sa couleur (dégradé ou gris) et d'afficher l'heure en dessous.
class BulleMessage extends StatelessWidget {
  final Map<String, dynamic> message;

  const BulleMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // 👤 Vérifie si c'est moi qui ai envoyé le message
    final estMoi = message["sender_id"] == ProfilData.userId;
    
    // ⏱️ Récupère l'heure ou la date grâce à ton nouveau fichier chat_time
    final String affichageTemps = ChatTimeParser.recupererHeureEtDate(message);

    return Align(
      alignment: estMoi ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: estMoi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 💬 LA BULLE DE TEXTE
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              // Si c'est moi : Super dégradé Yrion Cyberpunk
              gradient: estMoi ? const LinearGradient(
                colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              // Si c'est mon pote : Fond sombre transparent très épuré
              color: estMoi ? null : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(estMoi ? 22 : 4),  // Arrondi spécial selon le côté
                bottomRight: Radius.circular(estMoi ? 4 : 22), // Arrondi spécial selon le côté
              ),
            ),
            child: Text(
              message["text"] ?? '', 
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          
          // 🕒 L'AFFICHAGE DE L'HEURE (Sous la bulle)
          if (affichageTemps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
              child: Text(
                affichageTemps, 
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}