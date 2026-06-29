// lib/tocken/yrion_auth_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class YrionAuthStorage {
  static const _storage = FlutterSecureStorage();
  static const _cleToken = "yrion_quantique_token";

  // 💾 Sauvegarder le token
  static Future<void> sauvegarderToken(String token) async {
    await _storage.write(key: _cleToken, value: token);
    print("[YRION AUTH] Token sécurisé enregistré localement.");
  }

  // 📖 Lire le token
  static Future<String?> lireToken() async {
    return await _storage.read(key: _cleToken);
  }

  // 🧼 Supprimer le token (Déconnexion)
  static Future<void> supprimerToken() async {
    await _storage.delete(key: _cleToken);
    print("[YRION AUTH] Session détruite.");
  }
}

// coffre fort de token 