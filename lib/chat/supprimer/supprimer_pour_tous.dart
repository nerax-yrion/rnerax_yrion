import 'package:flutter/material.dart';

/// ⚙️ **LOGIQUE MÉTIER : SUPPRESSION GLOBALE**
/// Transmet l'ordre de destruction atomique au serveur pour effacer le message chez les deux utilisateurs.
class SupprimerPourTous {
  static Future<void> executer({
    required String messageId,
    required String salonId,
    required String expediteurId,
  }) async {
    final Map<String, dynamic> configSuppressionGlobale = {
      "target_message_id": messageId,
      "chat_room_id": salonId,
      "author_id": expediteurId,
      "scope": "GLOBAL_NETWORK_DESTROY",
      "server_hard_delete": true,
      "peer_to_peer_force_sync": true,
    };

    debugPrint("🚨 [Yrion Réseau] Ordre de destruction globale émis pour le message $messageId");
    debugPrint("📡 Synchronisation forcée des deux terminaux : ${configSuppressionGlobale['peer_to_peer_force_sync']}");
    
    // TODO: Insérer ici l'appel à ton API ou ton flux WebSocket (Firebase, Supabase, Node.js...)
    // await serviceChatReseau.emettreSuppression(messageId, salonId);
  }
}