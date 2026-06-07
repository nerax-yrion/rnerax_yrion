import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Classe de gestion des réponses de l'API pour isoler les erreurs proprement.
class AuthResult {
  final bool success;
  final String? message;
  final String? token;

  AuthResult({required this.success, this.message, this.token});
}

class AuthService {
  // Ton lien de serveur Render officiel configuré ensemble
  static const String _baseUrl = "https://yrion-backend.onrender.com";
  
  // Stockage chiffré au niveau du système d'exploitation (Keychain sur iOS, Keystore sur Android)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// 🔐 INSCRIPTION (Register)
  /// Envoie les données au backend FastAPI
  Future<AuthResult> register(String email, String password, String username) async {
    final Uri url = Uri.parse("$_baseUrl/inscription"); // Ajuste l'endpoint selon ton backend

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "username": username,
        }),
      ).timeout(const Duration(seconds: 15)); // Évite que l'application charge à l'infini si réseau faible

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult(success: true, message: "Compte créé avec succès !");
      } else {
        // Récupère l'erreur exacte renvoyée par FastAPI (ex: "Cet email est déjà utilisé")
        return AuthResult(success: false, message: data['detail'] ?? "Une erreur est survenue.");
      }
    } catch (e) {
      return AuthResult(
        success: false, 
        message: "Impossible de joindre le serveur. Vérifiez votre connexion internet.",
      );
    }
  }

  /// 🔑 CONNEXION (Login)
  /// Authentifie l'utilisateur et sauvegarde le token JWT de manière sécurisée
  Future<AuthResult> login(String email, String password) async {
    final Uri url = Uri.parse("$_baseUrl/connexion"); // Ajuste l'endpoint selon ton backend

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String? token = data['token']; // Assure-toi que ton FastAPI renvoie bien une clé 'token'
        
        if (token != null) {
          // Sauvegarde sécurisée et persistante du Token
          await _secureStorage.write(key: "auth_token", value: token);
          return AuthResult(success: true, token: token);
        }
        
        return AuthResult(success: false, message: "Protocole d'authentification invalide.");
      } else {
        return AuthResult(success: false, message: data['detail'] ?? "Identifiants incorrects.");
      }
    } catch (e) {
      return AuthResult(
        success: false, 
        message: "Erreur réseau. Connexion au serveur impossible.",
      );
    }
  }

  /// 📜 VÉRIFICATION DE SESSION (Auto-login)
  /// Permet de savoir si l'utilisateur est déjà connecté quand il ouvre l'application
  Future<String?> getToken() async {
    return await _secureStorage.read(key: "auth_token");
  }

  /// 🚪 DÉCONNEXION (Logout)
  /// Supprime le jeton de sécurité proprement
  Future<void> logout() async {
    await _secureStorage.delete(key: "auth_token");
  }
}