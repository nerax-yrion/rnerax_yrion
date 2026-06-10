import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';

// Imports des vues spécifiques
import 'nav_changer_mdp.dart';
import 'nav_liste_bloques.dart';
import 'nav_ajouter_blocage.dart';

class ParametresActions {
  
  /// Ouvrir un écran complet
  void _versGrandeNav(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  /// Ouvrir un panneau coulissant depuis le bas (Style Cyberpunk)
  void _versPetiteNav(BuildContext context, Widget widgetInterne) {
    showModalBottomSheet(
      context: context,
      backgroundColor: YrionTheme.spaceDeep,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: YrionTheme.cyanNeon.withOpacity(0.2)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: widgetInterne,
      ),
    );
  }

  // Actions utilisateur
  void ouvrirChangerMdp(BuildContext context) => _versPetiteNav(context, const NavChangerMdp());
  void ouvrirFormulaireBloquer(BuildContext context) => _versPetiteNav(context, const NavAjouterBlocage());
  
  void ouvrirListeBloques(BuildContext context) => _versGrandeNav(context, const NavListeBloquesPage());

  void actionEjection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("⚡ Déconnexion et nettoyage des tokens de session...")),
    );
  }
}