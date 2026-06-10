import 'package:flutter/material.dart';
import 'passions_bar.dart'; // Importation de ton nouveau composant séparé

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  // L'index sélectionné reste géré ici pour piloter le flux de posts
  int _selectedPassionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🌌 ENTÊTE D'ACCUEIL FUTURISTE
          Padding(
            padding: const EdgeInsets.only(top: 24.0, right: 20.0, left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Yrion",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00F0FF).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Explore tes passions autour de toi",
                      style: TextStyle(
                        color: Color(0xFF5D598C),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131127),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.radar_rounded, color: Color(0xFF00F0FF), size: 22),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// 🏷️ INJECTION DE TON NOUVEAU COMPOSANT "PASSIONS BAR"
          PassionsBar(
            selectedIndex: _selectedPassionIndex,
            onPassionChanged: (index) {
              setState(() {
                _selectedPassionIndex = index;
              });
              // Tu pourras ajouter ici la logique pour charger les posts de la passion choisie
            },
          ),

          const SizedBox(height: 18),

          /// 📜 FIL D'ACTUALITÉ LOCAL ET INTERACTIF
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 20.0, left: 10.0, bottom: 20.0),
              itemCount: 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFeedPost(
                    username: "Lila_Code",
                    userAvatar: "https://i.pravatar.cc/150?img=47",
                    passionBadge: "Flutter - Antananarivo",
                    locationInfo: "À 1.5 km de toi",
                    timeAgo: "Il y a 10 min",
                    content: "J'ai enfin terminé l'interface d'Yrion en utilisant Flutter ! Des passionnés à Tana pour tester l'APK en local et me faire des retours ? 💻✨",
                    hasImage: true,
                    imageUrl: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=60&w=500",
                    fireCount: "24",
                    commentCount: "12",
                  );
                } else {
                  return _buildFeedPost(
                    username: "Marc_Cuisto",
                    userAvatar: "https://i.pravatar.cc/150?img=33",
                    passionBadge: "Cuisine - Antananarivo",
                    locationInfo: "Analamanga",
                    timeAgo: "Il y a 1 h",
                    content: "Deuxième tentative de soufflé au chocolat... Il a totalement dégonflé en sortant du four 😭. Quelqu'un sur Tana connaît l'astuce avec l'humidité locale ?",
                    hasImage: false,
                    imageUrl: "",
                    fireCount: "15",
                    commentCount: "42",
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedPost({
    required String username,
    required String userAvatar,
    required String passionBadge,
    required String locationInfo,
    required String timeAgo,
    required String content,
    required bool hasImage,
    required String imageUrl,
    required String fireCount,
    required String commentCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF131127).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF252147).withOpacity(0.4), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(userAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F0FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4), width: 0.8),
                          ),
                          child: Text(
                            passionBadge,
                            style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFFFF00D6), size: 12),
                        const SizedBox(width: 2),
                        Text(
                          "$locationInfo • $timeAgo",
                          style: const TextStyle(color: Color(0xFF5D598C), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(color: Color(0xFFBCBABE), fontSize: 14, height: 1.4),
          ),
          if (hasImage) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: const Color(0xFF252147).withOpacity(0.4), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInteractionButton(
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFFF00D6),
                count: fireCount,
                label: "Intéressés",
              ),
              const SizedBox(width: 24),
              _buildInteractionButton(
                icon: Icons.chat_bubble_outline_rounded,
                color: const Color(0xFF00F0FF),
                count: commentCount,
                label: "Réactions",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required Color color,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF070512).withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            "$count $label",
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}