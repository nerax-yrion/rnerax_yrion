import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'chat_user_model.dart';
import 'chat_service.dart';
import '../profil/profil_data.dart';

class ChatRoomPage extends StatefulWidget {
  final ChatUser destinataire;
  const ChatRoomPage({super.key, required this.destinataire});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _abonnementFlux;
  
  List<Map<String, dynamic>> _messages = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
    _brancherTempsReel();
  }

  Future<void> _chargerHistorique() async {
    final historique = await _chatService.recupererHistorique(widget.destinataire.id);
    if (mounted) {
      setState(() {
        _messages = historique;
        _chargement = false;
      });
      _scrollerVersLeBas(immediat: true);
    }
  }

  void _brancherTempsReel() {
    _abonnementFlux = _chatService.fluxMessages.listen((msg) {
      final String expediteur = msg["sender_id"] ?? "";
      final String destinataire = msg["receiver_id"] ?? "";

      bool correspondAuSalon = (expediteur == ProfilData.userId && destinataire == widget.destinataire.id) ||
                               (expediteur == widget.destinataire.id && destinataire == ProfilData.userId);

      if (correspondAuSalon && mounted) {
        setState(() {
          _messages.add(msg);
        });
        _scrollerVersLeBas();
      }
    });
  }

  void _envoyer() {
    final texte = _controller.text.trim();
    if (texte.isEmpty) return;

    _chatService.envoyerMessageTempsReel(
      destinataireId: widget.destinataire.id,
      texte: texte,
    );
    _controller.clear();
  }

  void _scrollerVersLeBas({bool immediat = false}) {
    Future.delayed(Duration(milliseconds: immediat ? 50 : 150), () {
      if (_scrollController.hasClients) {
        if (immediat) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _abonnementFlux?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070512),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white10,
              backgroundImage: widget.destinataire.avatarUrl != null ? NetworkImage(widget.destinataire.avatarUrl!) : null,
              child: widget.destinataire.avatarUrl == null ? Text(widget.destinataire.pseudo[0]) : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.destinataire.pseudo, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(widget.destinataire.enLigne ? "En ligne" : "Hors ligne", style: TextStyle(color: widget.destinataire.enLigne ? Colors.greenAccent : Colors.white30, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chargement
                ? const Center(child: CircularProgressIndicator(color: YrionTheme.cyanNeon))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final estMoi = msg["sender_id"] == ProfilData.userId;

                      return Align(
                        alignment: estMoi ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            gradient: estMoi ? const LinearGradient(
                              colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ) : null,
                            color: estMoi ? null : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(22),
                              topRight: const Radius.circular(22),
                              bottomLeft: Radius.circular(estMoi ? 22 : 4),
                              bottomRight: Radius.circular(estMoi ? 4 : 22),
                            ),
                          ),
                          child: Text(msg["text"] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Écris ton message...",
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _envoyer,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFF8A2387), Color(0xFFE94057)]),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}