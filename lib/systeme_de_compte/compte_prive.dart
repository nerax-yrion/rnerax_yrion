import 'package:flutter/material.dart';
import '../message/chat_user_model.dart';
import '../message/chat_room_page.dart';

class ComptePublic {
  /// 🔓 Ouvre directement le salon de discussion sans restriction
  static void ouvrirDiscussionDirecte(BuildContext context, ChatUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(destinataire: user),
      ),
    );
  }
}