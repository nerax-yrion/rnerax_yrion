import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'chat_user_model.dart';
import '../chat/chat_room_page.dart';

class CurvedFriendsList extends StatefulWidget {
  final List<ChatUser> amis;
  const CurvedFriendsList({super.key, required this.amis});

  @override
  State<CurvedFriendsList> createState() => _CurvedFriendsListState();
}

class _CurvedFriendsListState extends State<CurvedFriendsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListWheelScrollView.useDelegate(
      controller: _scrollController,
      itemExtent: 95, 
      perspective: 0.0035,
      diameterRatio: 2.0, 
      physics: const BouncingScrollPhysics(),
      squeeze: 0.98,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: widget.amis.length,
        builder: (context, index) {
          final ami = widget.amis[index];

          return AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              double offset = 0.0;
              if (_scrollController.hasClients) {
                offset = _scrollController.offset;
              }

              final double itemPosition = index * 95.0;
              final double difference = itemPosition - offset;
              final double distanceFromCenter = (difference / (size.height * 0.45)).clamp(-1.0, 1.0);

              // Équation orbitale de ta maquette Yo
              final double translateX = (1.0 - (distanceFromCenter * distanceFromCenter)) * -55.0 + 40.0;
              final double scale = 1.0 - (distanceFromCenter.abs() * 0.14);
              final double opacity = 1.0 - (distanceFromCenter.abs() * 0.45);

              return Transform(
                transform: Matrix4.identity()
                  ..translate(translateX, 0.0)
                  ..scale(scale),
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: opacity.clamp(0.15, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 35.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatRoomPage(destinataire: ami)),
                        );
                      },
                      child: _buildCyberCapsule(ami),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCyberCapsule(ChatUser ami) {
    return Container(
      height: 78,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.01)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ami.enLigne ? YrionTheme.cyanNeon.withOpacity(0.3) : Colors.white.withOpacity(0.06),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black38,
                backgroundImage: ami.avatarUrl != null ? NetworkImage(ami.avatarUrl!) : null,
                child: ami.avatarUrl == null
                    ? Text(ami.pseudo[0].toUpperCase(), style: const TextStyle(color: YrionTheme.cyanNeon, fontWeight: FontWeight.bold))
                    : null,
              ),
              if (ami.enLigne)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF070512), width: 1.8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ami.pseudo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                const SizedBox(height: 3),
                Text(
                  ami.enLigne ? "En ligne" : "Hors ligne",
                  style: TextStyle(color: ami.enLigne ? Colors.greenAccent : Colors.white24, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.12), size: 12),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}