import 'package:flutter/material.dart';

class SplitInteractionsSidebar extends StatefulWidget {
  final Map<String, dynamic> splitData;

  const SplitInteractionsSidebar({
    super.key,
    required this.splitData,
  });

  @override
  State<SplitInteractionsSidebar> createState() => _SplitInteractionsSidebarState();
}

class _SplitInteractionsSidebarState extends State<SplitInteractionsSidebar> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 1. PROFILE DU CRÉATEUR + BOUTON SUIVRE
        GestureDetector(
          onTap: () {
            // TODO: Redirection Profil Auteur
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00D2FF), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 23,
                  backgroundColor: Color(0xFF171334),
                  child: Icon(Icons.person, color: Colors.white54), // Remplacer par NetworkImage plus tard
                ),
              ),
              Positioned(
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9D00FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        /// 2. BOUTON LIKE (CŒUR)
        _buildButton(
          icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _isLiked ? const Color(0xFFFF0055) : Colors.white,
          count: '12.2K',
          onTap: () {
            setState(() {
              _isLiked = !_isLiked;
            });
          },
        ),
        const SizedBox(height: 20),

        /// 3. BOUTON COMMENTAIRE
        _buildButton(
          icon: Icons.mode_comment_rounded,
          color: Colors.white,
          count: '53',
          onTap: () {
            // TODO: Ouvrir BottomSheet de commentaires
          },
        ),
        const SizedBox(height: 20),

        /// 4. BOUTON FUSÉE (RELAIS / PARTAGE)
        _buildButton(
          icon: Icons.rocket_launch_rounded,
          color: const Color(0xFF9D00FF),
          count: 'Relayer',
          onTap: () {
            // TODO: Partage natif
          },
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required String count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF171334).withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}