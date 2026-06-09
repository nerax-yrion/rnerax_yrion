import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  // Simulation des données qui viendront de ton serveur Python FastAPI
  final List<Map<String, dynamic>> _amis = [
    {"nom": "Camille", "enLigne": true, "avatar": "https://i.pravatar.cc/150?img=47"},
    {"nom": "Alex", "enLigne": true, "avatar": "https://i.pravatar.cc/150?img=33"},
    {"nom": "Lucas", "enLigne": true, "avatar": "https://i.pravatar.cc/150?img=12"},
    {"nom": "Sophie", "enLigne": true, "avatar": "https://i.pravatar.cc/150?img=49"},
    {"nom": "Thomas", "enLigne": false, "avatar": "https://i.pravatar.cc/150?img=60"},
    {"nom": "Chloé", "enLigne": false, "avatar": "https://i.pravatar.cc/150?img=26"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Laisse voir le fond de la NavigationPage
      body: Stack(
        children: [
          /// 🌌 FOND COSMIQUE ET ORBITES (Lignes d'orbite subtiles en arrière-plan)
          Positioned.fill(
            child: CustomPaint(
              painter: OrbitPainter(),
            ),
          ),

          /// 🪐 CONTENU PRINCIPAL EN SCROLL
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// 🟢 EMBLEMENT 1 : LOGO "YO" EN HAUT (Entouré en vert)
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFFFF00D6), Color(0xFF6A00FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'YO',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    'Tes amis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// 🔍 BARRE DE RECHERCHE (Entourée en blanc sur ta maquette)
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131127).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF252147)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF5D598C), size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Rechercher',
                              hintStyle: TextStyle(color: Color(0xFF5D598C), fontSize: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// 👥 LISTE DES AMIS INCLINÉE EN ARC DE CERCLE (Entourée en rouge)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _amis.length,
                    itemBuilder: (context, index) {
                      // Calcul mathématique de l'inclinaison/décalage pour épouser la courbe de la planète
                      double leftMargin = 0.0;
                      if (index == 0) leftMargin = 55.0;
                      if (index == 1) leftMargin = 30.0;
                      if (index == 2) leftMargin = 15.0;
                      if (index == 3) leftMargin = 20.0;
                      if (index == 4) leftMargin = 45.0;
                      if (index == 5) leftMargin = 75.0;

                      final ami = _amis[index];

                      return Container(
                        margin: EdgeInsets.only(left: leftMargin, bottom: 16, right: 10),
                        child: _buildFriendCard(
                          nom: ami["nom"],
                          enLigne: ami["enLigne"],
                          avatarUrl: ami["avatar"],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100), // Espace pour ne pas cacher le bas
                ],
              ),
            ),
          ),

          /// 🟢 EMBLEMENT 2 : LA PLANÈTE LOGO "YO" À DROITE (Entourée en vert)
          Positioned(
            right: -20,
            top: MediaQuery.of(context).size.height * 0.38,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6A00FF).withOpacity(0.5),
                    const Color(0xFF00F0FF).withOpacity(0.2),
                    Colors.transparent
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF00D6).withOpacity(0.25),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Center(
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5), width: 1.5),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF140D30), Color(0xFF070414)],
                    ),
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00F0FF), Color(0xFFFF00D6)],
                      ).createShader(bounds),
                      child: const Text(
                        'YO',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 🔵 BOUTON FLOTTANT "+" EN BAS À DROITE (Entouré en bleu)
          Positioned(
            right: 25,
            bottom: 30,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F0C2C), Color(0xFF050314)],
                ),
                border: Border.all(color: const Color(0xFF1F1A4A), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour construire les capsules de message en verre biseauté (Glassmorphism)
  Widget _buildFriendCard({required String nom, required bool enLigne, required String avatarUrl}) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        // Fond translucide effet verre violet de ta maquette
        gradient: LinearGradient(
          colors: [
            const Color(0xFF261852).withOpacity(0.45),
            const Color(0xFF110B29).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: enLigne 
              ? const Color(0xFFFF00D6).withOpacity(0.35) // Bordure magentane si connecté
              : const Color(0xFF32295B).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // Avatar avec le point de statut vert
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.5), width: 1),
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (enLigne)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF66), // Vert néon d'activité
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0A061E), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Nom et Statut textuel
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nom,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                enLigne ? 'En ligne' : 'Hors ligne',
                style: TextStyle(
                  color: enLigne ? const Color(0xFF00FF66) : const Color(0xFF5D598C),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dessinateur personnalisé pour tracer l'orbite elliptique en arrière-plan
class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF231B4D).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Tracé de l'arc orbitaire passant derrière les cartes
    final center = Offset(size.width * 1.0, size.height * 0.45);
    canvas.drawCircle(center, size.width * 0.75, paint);
    canvas.drawCircle(center, size.width * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}