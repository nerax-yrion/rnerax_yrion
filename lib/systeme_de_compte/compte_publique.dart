import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nerax_yrion/theme/yrion_theme.dart';
import '../message/chat_user_model.dart';
import '../chat/chat_room_page.dart';
import '../../profil/profil_data.dart'; // Double-remontée (../..) pour atteindre le dossier profil

class ComptePrive {
  static const String _baseUrl = "https://ton-api-render.com/api";

  /// 🛡️ Vérifie les droits d'accès sur Neon SQL
  static Future<void> gererAccesPrive(BuildContext context, ChatUser user) async {
    bool estAmiOuSuivi = false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/relations/check?user_id=${ProfilData.userId}&target_id=${user.id}'),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String relation = data['statut_relation'];
        if (relation == 'amis' || relation == 'suit') {
          estAmiOuSuivi = true;
        }
      }
    } catch (e) {
      print("Erreur contrôle intimité : $e");
    }

    if (estAmiOuSuivi) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatRoomPage(destinataire: user)),
      );
    } else {
      _afficherDialogueDemande(context, user);
    }
  }

  /// 📩 Envoi de la demande en tâche de fond
  static Future<bool> _envoyerDemande(String cibleId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages/request'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "expediteur_id": ProfilData.userId,
          "destinataire_id": cibleId,
          "contenu": message,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// 🎨 Fenêtre pop-up "Demande de message"
  static void _afficherDialogueDemande(BuildContext context, ChatUser user) {
    final TextEditingController msgController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C091F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, color: YrionTheme.cyanNeon, size: 32),
            const SizedBox(height: 12),
            Text(
              "${user.pseudo} est Privé",
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Ton premier message sera placé dans ses demandes de messages pour préserver son espace personnel.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: msgController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Écris une invitation polie...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: YrionTheme.cyanNeon,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (msgController.text.trim().isNotEmpty) {
                  bool succes = await _envoyerDemande(user.id, msgController.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(succes ? "Demande transmise avec succès ✨" : "Échec de l'opération"),
                      backgroundColor: const Color(0xFF9D00FF),
                    ),
                  );
                }
              },
              child: const Text("Envoyer la demande", style: TextStyle(color: Color(0xFF070512), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}