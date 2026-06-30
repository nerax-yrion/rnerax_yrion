// lib/theme/yrion_time_enum.dart

enum YrionTimeMode {
  matin,      // Aurore boréale
  midi,       // Chaleur galactique
  apresMidi,  // Violet Néon Noir Rose
  nuit        // Ton image signature sombre
}

class YrionTimeEngine {
  static YrionTimeMode obtenirModeActuel() {
    final int heure = DateTime.now().hour;
    
    if (heure >= 6 && heure < 12) {
      return YrionTimeMode.matin;
    } else if (heure >= 12 && heure < 15) {
      return YrionTimeMode.midi;
    } else if (heure >= 15 && heure < 19) {
      return YrionTimeMode.apresMidi;
    } else {
      return YrionTimeMode.nuit;
    }
  }
}