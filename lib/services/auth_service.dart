import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // 🐍 Serveur PYTHON (FastAPI) : Uniquement responsable de la navigation et du contenu
  static const String _baseUrl = "https://yrion-backend.onrender.com";
  
  // Stockage chiffré pour récupérer le token de session
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// 📜 VÉRIFICATION DE SESSION (Auto-login)
  /// Permet au main.dart de savoir si un utilisateur est déjà connecté
  Future<String?> getToken() async {
    return await _secureStorage.read(key: "auth_token");
  }

  /// 🚪 DÉCONNEXION
  /// Supprime le jeton pour détruire la session proprement
  Future<void> logout() async {
    await _secureStorage.delete(key: "auth_token");
  }

  /// 🌐 RÉCUPÉRER LES DONNÉES DE LA NAVIGATION
  /// Appelé par tes pages (accueil.dart, profil.dart, etc.) pour charger le contenu depuis Python
  Future<Map<String, dynamic>> recupererDonneesNavigation(String endpoint) async {
    final Uri url = Uri.parse("$_baseUrl/$endpoint");
    final String? token = await getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Envoie le token pour prouver au serveur Python qu'on est connecté
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {
          "success": true, 
          "data": jsonDecode(response.body)
        };
      } else {
        return {
          "success": false, 
          "message": "Erreur serveur (${response.statusCode}). Impossible de charger les données."
        };
      }
    } catch (e) {
      return {
        "success": false, 
        "message": "Impossible de joindre le serveur Python. Vérifiez votre connexion internet."
      };
    }
  }
}