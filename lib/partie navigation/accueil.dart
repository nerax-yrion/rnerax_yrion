import 'package:flutter/material.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text(
          "YO",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// POST
          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(25),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// USER
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.purple,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      "Shami",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// MESSAGE
                const Text(
                  "Je travaille encore sur YO 🔥",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 20),

                /// REACTIONS
                Row(
                  children: [

                    reactionButton("🔥 12"),
                    const SizedBox(width: 10),

                    reactionButton("❤️ 5"),
                    const SizedBox(width: 10),

                    reactionButton("😭 2"),
                  ],
                ),

                const SizedBox(height: 15),

                /// COMMENTAIRE
                Container(
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: const Color(0xFF252542),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: const Text(
                    "Force à toi 🔥",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget reactionButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF252542),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}