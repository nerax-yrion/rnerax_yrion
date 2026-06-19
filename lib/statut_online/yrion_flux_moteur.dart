import 'package:flutter/material.dart';

class YrionFluxMoteur {
  // Canaux de diffusion indépendants (Zéro couplage, performance maximale)
  static final ValueNotifier<bool> fluxEstLaNuit = ValueNotifier<bool>(false);
  static final ValueNotifier<String> fluxEmoji = ValueNotifier<String>("☀️");
  static final ValueNotifier<Color> fluxLueur = ValueNotifier<Color>(const Color(0xFFFF9100));

  // 🛠️ CORRECTION : En Dart, le mot-clé "private" n'existe pas. 
  // On utilise uniquement "static" et le "_" devant le nom pour rendre la variable privée.
  static int _derniereHeureCalculee = -1;

  /// ⚡ Le Worker : Calcule et distribue uniquement si l'heure système a pivoté
  static void synchroniserMoteur() {
    final int heureActuelle = DateTime.now().toLocal().hour;
    
    // Évite les calculs redondants si l'heure n'a pas changé (Gain de CPU énorme)
    if (heureActuelle == _derniereHeureCalculee) return;
    _derniereHeureCalculee = heureActuelle;

    final bool nuit = heureActuelle >= 17 || heureActuelle < 7;
    
    // Diffusion atomique dans les canaux
    fluxEstLaNuit.value = nuit;
    fluxEmoji.value = nuit ? "🌙" : "☀️";

    if (nuit) {
      fluxLueur.value = heureActuelle >= 22 || heureActuelle < 4 
          ? const Color(0xFF7000FF)  // Deep Cyber Violet
          : const Color(0xFF00E5FF); // Cyber Cyan
    } else {
      fluxLueur.value = heureActuelle >= 11 && heureActuelle <= 14
          ? const Color(0xFFFFD700)  // Hyper Gold
          : const Color(0xFFFF9100); // Neon Orange
    }
  }
}

/* ===============================================================================
💡 EXPLICATION DE CE QUE FAIT CE FICHIER (À LIRE POUR BIEN COMPRENDRE)
===============================================================================

Ce fichier est le "Cerveau Temporel" d'Yrion. Il fonctionne comme une station de radio :

1. LES EMETTEURS (ValueNotifier) :
   - `fluxEstLaNuit`, `fluxEmoji` et `fluxLueur` sont des canaux de diffusion en temps réel.
   - Ils contiennent des valeurs (vrai/faux, un emoji, ou une couleur) que n'importe quel 
     widget de l' application peut écouter.

2. LE TRAVAILLEUR (synchroniserMoteur) :
   - C'est une fonction "Static", ce qui signifie qu'on peut l'appeler partout sans créer 
     le fichier en mémoire (ex: YrionFluxMoteur.synchroniserMoteur()).
   - Elle regarde l'heure du smartphone de l'utilisateur.
   - Elle vérifie si l'heure a changé grâce à `_derniereHeureCalculee`. Si l'heure est la même 
     qu'au calcul précédent, elle s'arrête immédiatement (économie totale de batterie).

3. LA DISTRIBUTION :
   - Si l'heure a pivoté, le moteur décide si c'est la nuit ou le jour.
   - Il change l'emoji (🌙 ou ☀️) et choisit la couleur néon exacte (Violet, Cyan, Or, Orange).
   - Dès que ces valeurs changent, tous tes Avatars connectés reçoivent l'information 
     instantanément et changent de couleur sur l'écran sans que l'application ait besoin 
     de rafraîchir toute la page.
*/