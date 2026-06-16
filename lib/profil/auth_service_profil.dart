import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// ====================================================================
/// YRION SOCIAL ECOSYSTEM : MOTORISATION DE NAVIGATION & IDENTITY CORRIDOR
/// COMPATIBILITÉ RUST PRODUCTION : AXUM MULTIPART & NEON SQL ASYNC
/// LIAISON PRODUCTION RENDER : FREE ENGINE ROBUSTNESS ENGINE
/// ====================================================================
class AuthServiceProfil {
  // 🔥 L'URL officielle et sécurisée de ton microservice profil hébergé sur Render
  static const String baseUrl = "https://yrion-backend-profil.onrender.com/api";

  // En-têtes standards réutilisables pour forcer l'échange de JSON natif
  static const Map<String, String> _headersJson = {
    "Content-Type": "application/json; charset=UTF-8",
    "Accept": "application/json",
  };

  /// 👤 1. RÉCUPÉRATION DE TOUS LES PROFILS PLANÉTAIRES
  /// Scanne et désérialise dynamiquement la table user_profiles issue de Neon.
  Future<Map<String, dynamic>?> obtenirTousLesProfils() async {
    try {
      final url = Uri.parse('$baseUrl/utilisateurs');
      final reponse = await http.get(url, headers: {"Accept": "application/json"});

      if (reponse.statusCode == 200) {
        // Décodage forcé en UTF-8 pour garantir la stabilité des bios et des pseudos
        final String corpsDecode = utf8.decode(reponse.bodyBytes);
        return jsonDecode(corpsDecode) as Map<String, dynamic>;
      } else {
        print("⚠️ [AUTH PROFIL SERVICE] Échec de récupération globale (Status Code: ${reponse.statusCode})");
        return null;
      }
    } catch (e) {
      print("❌ [AUTH PROFIL SERVICE] Erreur réseau lors du scan global: $e");
      return null;
    }
  }

  /// 📝 2. ACTUALISATION DES TEXTES DU PROFIL (PSEUDO & BIO)
  /// Envoie une charge utile JSON chiffrée à ton contrôleur de mise à jour Axum.
  Future<bool> actualiserTextesProfil({
    required String userId,
    required String nouveauPseudo,
    required String nouvelleBio,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/profil/modifier/textes');
      
      final reponse = await http.post(
        url,
        headers: _headersJson,
        body: jsonEncode({
          "user_id": userId,
          "pseudo": nouveauPseudo,
          "bio": nouvelleBio,
        }),
      );

      if (reponse.statusCode == 200 || reponse.statusCode == 201) {
        print("✅ [AUTH PROFIL SERVICE] Synchronisation des textes réussie sur Yrion Cloud.");
        return true;
      } else {
        print("⚠️ [AUTH PROFIL SERVICE] Rejet des modifications par l'API Rust (Status Code: ${reponse.statusCode})");
        return false;
      }
    } catch (e) {
      print("❌ [AUTH PROFIL SERVICE] Échec de connexion réseau pour les textes: $e");
      return false;
    }
  }

  /// 📸 3. TRANSFERT INITIAL DE L'AVATAR (MULTIPART / PIPELINE BINAIRE)
  /// Expédie l'image brute fragmentée vers le décodeur multipart de ton backend.
  Future<String?> enregistrerNouvelAvatar({
    required String userId,
    required File fichierImage,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/profil/avatar/enregistrer');
      
      // Initialisation de la requête Multipart asynchrone industrielle
      final requete = http.MultipartRequest('POST', url);
      
      // Injection de l'identifiant utilisateur unique pour la liaison SQL
      requete.fields['user_id'] = userId;
      
      // Configuration et encapsulation sécurisée du binaire de l'image
      final fluxFichier = await http.MultipartFile.fromPath(
        'avatar', // Doit correspondre exactement au champ scruté par ton formulaire Axum
        fichierImage.path,
      );
      requete.files.add(fluxFichier);

      print("📤 [AUTH PROFIL SERVICE] Expédition binaire de l'avatar vers Render...");
      final fluxReponse = await requete.send();
      final reponse = await http.Response.fromStream(fluxReponse);

      if (reponse.statusCode == 200) {
        final String corpsDecode = utf8.decode(reponse.bodyBytes);
        final Map<String, dynamic> donnees = jsonDecode(corpsDecode) as Map<String, dynamic>;
        print("✅ [AUTH PROFIL SERVICE] Avatar stocké avec succès. Chemin racine mis à jour.");
        return donnees['profile_image_path'] as String?;
      } else {
        print("⚠️ [AUTH PROFIL SERVICE] Serveur Rust réfractaire au fichier (Status Code: ${reponse.statusCode})");
        return null;
      }
    } catch (e) {
      print("❌ [AUTH PROFIL SERVICE] Erreur critique lors de l'upload de l'avatar: $e");
      return null;
    }
  }

  /// 🔄 4. REMPLACEMENT FLUIDE DE L'AVATAR
  /// Écrase l'ancienne référence de l'avatar pour nettoyer l'espace disque.
  Future<bool> remplacerAvatar({
    required String userId,
    required File nouveauFichierImage,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/profil/avatar/remplacer');
      final requete = http.MultipartRequest('POST', url);
      
      requete.fields['user_id'] = userId;
      
      final fluxFichier = await http.MultipartFile.fromPath(
        'avatar',
        nouveauFichierImage.path,
      );
      requete.files.add(fluxFichier);

      print("🔄 [AUTH PROFIL SERVICE] Remplacement de l'avatar sur le cluster Render...");
      final fluxReponse = await requete.send();
      
      if (fluxReponse.statusCode == 200) {
        print("✅ [AUTH PROFIL SERVICE] Remplacement de l'avatar validé.");
        return true;
      } else {
        print("⚠️ [AUTH PROFIL SERVICE] Échec de la procédure de substitution (Status Code: ${fluxReponse.statusCode})");
        return false;
      }
    } catch (e) {
      print("❌ [AUTH PROFIL SERVICE] Erreur réseau lors de la substitution de l'avatar: $e");
      return false;
    }
  }
}