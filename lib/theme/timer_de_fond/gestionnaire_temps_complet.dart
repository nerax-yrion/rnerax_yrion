// lib/theme/timer_de_fond/gestionnaire_temps_complet.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// ====================================================================
/// 🌌 1. DICTIONNAIRE DES PHASES TEMPORELLES D'YRION
/// ====================================================================
enum YrionTimeMode {
  matin,      // Aurore boréale
  midi,       // Chaleur galactique
  apresMidi,  // Violet Néon Noir Rose
  nuit        // Mon fond signature d'origine (Radial Gradient Cyber)
}

/// ====================================================================
/// ⏱️ 2. LE CERVEAU CENTRAL : GESTIONNAIRE TEMPS INDESTRUCTIBLE & ÉCO-ÉLITE
/// ====================================================================
/// Ce composant prévient l'interface graphique quand le thème doit changer.
/// Intègre désormais un bouclier anti-triche et anti-décalage horaire
/// sans consommer de batterie supplémentaire (0% CPU en tâche de fond).
class GestionnaireTemps extends ChangeNotifier with WidgetsBindingObserver {
  YrionTimeMode _modeActuel = YrionTimeEngine.obtenirModeActuel();
  Timer? _prochainChangementTimer;

  /// Permet aux widgets (comme BackgroundSpace) de lire le mode actuel
  YrionTimeMode get modeActuel => _modeActuel;

  GestionnaireTemps() {
    // 🛡️ Étape Élite 1 : On inscrit le gestionnaire auprès des observateurs du système de l'appareil
    WidgetsBinding.instance.addObserver(this);
    _planifierProchainChangement();
  }

  /// 🛰️ Étape Élite 2 : Bouclier anti-triche / anti-voyage
  /// Cette fonction est automatiquement appelée par Flutter dès que l'état de l'application change.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Dès que l'utilisateur revient sur l'application (qu'il vienne de changer l'heure dans ses réglages ou d'atterrir à Tokyo)
    if (state == AppLifecycleState.resumed) {
      _verifierEtActualiserHeure();
    }
  }

  /// Évalue l'heure actuelle au retour de l'utilisateur pour corriger le tir si triche ou voyage
  void _verifierEtActualiserHeure() {
    final YrionTimeMode modeCalcule = YrionTimeEngine.obtenirModeActuel();
    
    // Si l'heure a sauté et que le mode n'est plus le bon, on force la mise à jour visuelle
    if (_modeActuel != modeCalcule) {
      _modeActuel = modeCalcule;
      notifyListeners(); // Lance le fondu progressif instantanément
    }
    
    // Dans tous les cas, on recalcule proprement la nouvelle attente pour le Timer
    _planifierProchainChangement();
  }

  /// Calcule la durée exacte d'attente et endort le thread.
  /// Aucune boucle de vérification répétitive n'est tolérée pour préserver l'autonomie.
  void _planifierProchainChangement() {
    // On annule proprement tout ancien timer pour éviter les fuites de mémoire
    _prochainChangementTimer?.cancel();

    // Calcul de la distance temporelle exacte jusqu'au prochain switch
    final Duration tempsAAttendre = YrionTimeEngine.calculerTempsRestantAvantProchainMode();

    // Le téléphone planifie une tâche de réveil unique auprès du système et coupe le traitement.
    _prochainChangementTimer = Timer(tempsAAttendre, () {
      _modeActuel = YrionTimeEngine.obtenirModeActuel();
      
      // On prévient l'AnimatedContainer de l'APK de lancer son fondu progressif d'une seconde
      notifyListeners(); 
      
      // On reprogramme immédiatement le réveil pour la phase suivante
      _planifierProchainChangement();
    });
  }

  @override
  void dispose() {
    // 🛡️ Nettoyage Élite : On désinscrit l'observateur pour libérer la mémoire proprement
    WidgetsBinding.instance.removeObserver(this);
    _prochainChangementTimer?.cancel();
    super.dispose();
  }
}

/// ====================================================================
/// 🛸 3. LE MOTEUR DE CALCUL STRATÉGIQUE (ZÉRO ERREUR FUSEAU HORAIRE)
/// ====================================================================
class YrionTimeEngine {
  
  /// Analyse l'heure locale et distribue instantanément la bonne carte d'identité visuelle
  static YrionTimeMode obtenirModeActuel() {
    final int heureLocale = DateTime.now().hour;
    
    if (heureLocale >= 6 && heureLocale < 12) {
      return YrionTimeMode.matin;     // 06h00 -> 11h59 : Aurore boréale
    } else if (heureLocale >= 12 && heureLocale < 15) {
      return YrionTimeMode.midi;      // 12h00 -> 14h59 : Chaleur galactique
    } else if (heureLocale >= 15 && heureLocale < 19) {
      return YrionTimeMode.apresMidi; // 15h00 -> 18h59 : Cyber Néon Rose Violet
    } else {
      return YrionTimeMode.nuit;      // 19h00 -> 05h59 : Ton fond signature sombre
    }
  }

  /// Calcule chirurgicalement l'écart à la milliseconde près vers la prochaine heure charnière
  static Duration calculerTempsRestantAvantProchainMode() {
    final DateTime maintenant = DateTime.now();
    final int heure = maintenant.hour;
    int heureCible;

    // Détermination de la prochaine barrière horaire à franchir
    if (heure >= 6 && heure < 12) {
      heureCible = 12; // Prochain arrêt : Midi
    } else if (heure >= 12 && heure < 15) {
      heureCible = 15; // Prochain arrêt : Après-midi
    } else if (heure >= 15 && heure < 19) {
      heureCible = 19; // Prochain arrêt : Nuit
    } else {
      heureCible = 6;  // Prochain arrêt : Matin (Aube du jour suivant)
    }

    // Création du point d'impact temporel pour aujourd'hui
    DateTime cible = DateTime(maintenant.year, maintenant.month, maintenant.day, heureCible);
    
    // Sécurité : Si l'heure cible est 6 (matin) et qu'il est par exemple 23h, 
    // la cible est au lendemain. On ajoute donc +1 jour au calendrier de calcul.
    if (cible.isBefore(maintenant)) {
      cible = cible.add(const Duration(days: 1));
    }

    // Retourne la soustraction exacte : Temps cible - Temps présent
    return cible.difference(maintenant);
  }
}
