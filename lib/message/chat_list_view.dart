import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'chat_user_model.dart';
import '../chat/chat_service.dart';
import 'curved_friends_list.dart';
import '../profil/profil_data.dart'; // Importation propre sans accent

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ChatService _chatService = ChatService();
  StreamSubscription? _abonnementMessages;
  
  List<ChatUser> _conversations = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chatService.connecterWebSocket();
    _chargerFluxInitial();
    _ecouterMisesAJour();
  }

  Future<void> _chargerFluxInitial() async {
    final liste = await _chatService.recupererDiscussionsActuelles();
    if (mounted) {
      setState(() {
        _conversations = liste;
        _chargement = false;
      });
    }
  }

  void _ecouterMisesAJour() {
    _abonnementMessages = _chatService.fluxMessages.listen((msg) {
      if (!mounted) return;

      final String expediteur = msg["sender_id"] ?? "";
      final String destinataire = msg["receiver_id"] ?? "";
      final String idInterlocuteur = (expediteur == ProfilData.userId) ? destinataire : expediteur;
      
      int indexExistant = _conversations.indexWhere((u) => u.id == idInterlocuteur);

      setState(() {
        if (indexExistant != -1) {
          final utilisateurMisAJour = _conversations.removeAt(indexExistant);
          _conversations.insert(0, utilisateurMisAJour); // Remonte tout en haut style WhatsApp
        } else {
          _chargerFluxInitial();
        }
      });
    });
  }

  @override
  void dispose() {
    _abonnementMessages?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070512),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -130,
              top: MediaQuery.of(context).size.height * 0.3,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [YrionTheme.magentaNeon.withOpacity(0.18), Colors.transparent],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 28, top: 24, bottom: 20),
                  child: Text(
                    "Messages",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
                Expanded(
                  child: _chargement
                      ? const Center(child: CircularProgressIndicator(color: YrionTheme.cyanNeon))
                      : _conversations.isEmpty
                          ? const Center(
                              child: Text(
                                "Aucune discussion active.",
                                style: TextStyle(color: Colors.white24, fontSize: 14),
                              ),
                            )
                          : CurvedFriendsList(amis: _conversations),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}