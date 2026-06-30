// lib/data/languages/global_languages_hub.dart
import 'europe_languages.dart';
import 'asia_languages.dart';
import 'africa_languages.dart';
import 'americas_languages.dart';
import 'mideast_languages.dart';
import 'islands_languages.dart';

class GlobalLanguagesHub {
  static final Map<String, List<Map<String, String>>> regionalRegistry = {
    "EUROPE ZONE": europeLanguages,
    "ASIA ZONE": asiaLanguages,
    "AFRICA ZONE": africaLanguages,
    "AMERICAS ZONE": americasLanguages,
    "MIDDLE EAST ZONE": mideastLanguages,
    "ISLANDS & OCEANIA ZONE": islandsLanguages,
  };
}


// le regrouper des langue  et classement 