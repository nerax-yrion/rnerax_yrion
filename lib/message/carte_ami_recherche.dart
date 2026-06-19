import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'chat_user_model.dart';
import '../systeme_de_compte/compte_publique.dart';
import '../systeme_de_compte/compte_prive.dart';

class CarteAmiRecherche extends StatelessWidget {
  final ChatUser user;
  final String queryText;
  final VoidCallback onTapCard;

  const CarteAmiRecherche({
    super.key,
    required this.user,
    required this.queryText,
    required this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // L'avatar est désormais épuré, sans aucun badge de statut en ligne
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white10,
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.pseudo[0].toUpperCase(), 
                  style: const TextStyle(color: YrionTheme.cyanNeon, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: _buildHighlightedText(user.pseudo, queryText, isTitle: true),
        subtitle: _buildHighlightedText("@${user.username}", queryText, isTitle: false),
        // Petite croix discrète pour l'historique, comme sur ton exemple
        trailing: Icon(
          Icons.close_rounded, 
          color: Colors.white.withOpacity(0.2), 
          size: 16,
        ),
        onTap: () {
          onTapCard(); // Sauvegarde locale de la recherche récente

          // Aiguillage intelligent selon la confidentialité du compte ciblé
          if (user.statutConfidentialite == 'public') {
            ComptePublic.ouvrirDiscussionDirecte(context, user);
          } else {
            ComptePrive.gererAccesPrive(context, user);
          }
        },
      ),
    );
  }

  /// 🎨 Algorithme d'analyse textuelle pour injecter le RichText Néon
  Widget _buildHighlightedText(String fullText, String searchField, {required bool isTitle}) {
    if (searchField.isEmpty || !fullText.toLowerCase().contains(searchField.toLowerCase())) {
      return Text(
        fullText, 
        style: TextStyle(
          color: isTitle ? Colors.white : Colors.white38, 
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal, 
          fontSize: isTitle ? 15 : 12
        ),
      );
    }

    final int startIdx = fullText.toLowerCase().indexOf(searchField.toLowerCase());
    final int endIdx = startIdx + searchField.length;

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: isTitle ? 15 : 12, fontFamily: 'sans-serif'),
        children: [
          TextSpan(
            text: fullText.substring(0, startIdx), 
            style: TextStyle(color: isTitle ? Colors.white : Colors.white38, fontWeight: isTitle ? FontWeight.bold : FontWeight.normal)
          ),
          TextSpan(
            text: fullText.substring(startIdx, endIdx),
            style: const TextStyle(color: YrionTheme.cyanNeon, fontWeight: FontWeight.bold), 
          ),
          TextSpan(
            text: fullText.substring(endIdx), 
            style: TextStyle(color: isTitle ? Colors.white : Colors.white38, fontWeight: isTitle ? FontWeight.bold : FontWeight.normal)
          ),
        ],
      ),
    );
  }
}