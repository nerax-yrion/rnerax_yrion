import 'package:flutter/material.dart';

class PassionsBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onPassionChanged;

  // Ta liste de communautés de départ ultra-ciblées pour la V1 d'Yrion
  final List<Map<String, dynamic>> _passions = [
    {"name": "Tout", "icon": Icons.rocket_launch_rounded},
    {"name": "Flutter", "icon": Icons.code_rounded},
    {"name": "Gaming", "icon": Icons.sports_esports_rounded},
    {"name": "Rap", "icon": Icons.music_note_rounded},
    {"name": "Dessin", "icon": Icons.palette_rounded},
    {"name": "Streetwear", "icon": Icons.checkroom_rounded},
    {"name": "Fitness", "icon": Icons.fitness_center_rounded},
    {"name": "Business", "icon": Icons.trending_up_rounded},
  ];

  PassionsBar({
    super.key,
    required this.selectedIndex,
    required this.onPassionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 10.0),
        itemCount: _passions.length,
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onPassionChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                // Gradient Néon unique d'Yrion pour la tribu active
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFFFF00D6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF131127).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? Colors.transparent 
                      : const Color(0xFF252147).withOpacity(0.5),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00F0FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    _passions[index]["icon"],
                    color: isSelected ? Colors.white : const Color(0xFF5D598C),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _passions[index]["name"],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFBCBABE),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}