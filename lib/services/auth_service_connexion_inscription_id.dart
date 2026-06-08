import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 🌐 L'URL de ta Forteresse Rust sur Render
  // REMPLACE par ton vrai sous-domaine Render si nécessaire (ex: https://backend-connexion-inscription-id-rust.onrender.com)
  static const String baseUrl = "https://backend-connexion-inscription-id-rust.onrender.com/api/auth";

  /// 🛡️ MONDIAUX YRION : INSCRIPTION D'UN NOUVEL UTILISATEUR
  Future<Map<String, dynamic>> inscrireUtilisateur({
    required String username,
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Succès : Compte créé et immunisé
        if (data['token'] != null && data['user_id'] != null) {
          await _sauvegarderSession(data['token'], data['user_id']);
        }
        return {"success": true, "message": data['message'], "user_id": data['user_id']};
      } else {
        // Erreurs gérées par Rust (Champs invalides, doublons, etc.)
        return {"success": false, "message": data['message'] ?? "Une erreur est survenue."};
      }
    } catch (e) {
      return {"success": false, "message": "Impossible de joindre le serveur Yrion. Vérifie ta connexion."};
    }
  }

  /// 🔑 MONDIAUX YRION : CONNEXION DE L'UTILISATEUR
  Future<Map<String, dynamic>> connecterUtilisateur({
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Connexion réussie
        if (data['token'] != null && data['user_id'] != null) {
          await _sauvegarderSession(data['token'], data['user_id']);
        }
        return {"success": true, "message": data['message'], "user_id": data['user_id']};
      } else {
        return {"success": false, "message": data['message'] ?? "Identifiants incorrects."};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur de connexion au serveur cloud."};
    }
  }

  /// 📦 SAUVEGARDE LOCALE SÉCURISÉE (Token & ID Unique)
  Future<void> _sauvegarderSession(String token, String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('yrion_token', token);
    await prefs.setString('yrion_user_id', userId);
  }

  /// 🔓 RÉCUPÉRER LE TOKEN ACTUEL (Pour authentifier tes futures requêtes)
  Future<String?> obtenirToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('yrion_token');
  }

  /// 👤 RÉCUPÉRER L'UUID DE L'UTILISATEUR CONNECTÉ
  Future<String?> obtenirUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('yrion_user_id');
  }

  /// 🚪 DÉCONNEXION (Nettoyage du stockage local)
  Future<void> deconnecter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('yrion_token');
    await prefs.remove('yrion_user_id');
  }
}