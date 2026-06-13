import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  // Structure de données réelle prête pour ton backend Rust/FastAPI
  final List<Map<String, dynamic>> _userSplits = [
    {
      "id": 101,
      "type": "text", // Format 1: Pur texte
      "question": "Pour ton avenir pro, tu choisis quoi ?",
      "optionA": "Gagner 10k€/mois dans un taf chiant",
      "optionB": "Le SMIC mais tu vis de ta passion",
      "votesA": 142,
      "votesB": 89,
      "userVoted": null,
    },
    {
      "id": 102,
      "type": "image", // Format 2: Image
      "mediaUrl": "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=500", // Exemple d'image tech/néon
      "question": "CE LOOK POUR LA CONFIG DE JEU :",
      "optionA": "Masterclass absolue",
      "optionB": "Trop de RGB, poubelle",
      "votesA": 512,
      "votesB": 498,
      "userVoted": null,
    },
    {
      "id": 103,
      "type": "video", // Format 3: Vidéo (Style TikTok)
      "mediaUrl": "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4", // Exemple de flux vidéo
      "question": "JE SUIS DRÔLE OU JE SUIS CON ?",
      "optionA": "Franchement drôle",
      "optionB": "Grand con",
      "votesA": 24,
      "votesB": 26,
      "userVoted": null,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _userSplits.length,
      itemBuilder: (context, index) {
        final split = _userSplits[index];
        return SplitCard(
          key: ValueKey(split['id']), // Force Flutter à détruire/recréer proprement le widget au scroll
          splitData: split,
          onVote: (choice) {
            setState(() {
              split['userVoted'] = choice;
              if (choice == 'A') {
                split['votesA']++;
              } else {
                split['votesB']++;
              }
            });
          },
        );
      },
    );
  }
}

class SplitCard extends StatefulWidget {
  final Map<String, dynamic> splitData;
  final Function(String) onVote;

  const SplitCard({
    super.key,
    required this.splitData,
    required this.onVote,
  });

  @override
  State<SplitCard> createState() => _SplitCardState();
}

class _SplitCardState extends State<SplitCard> {
  VideoPlayerController? _videoController;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    // Si le Split de l'utilisateur contient une vidéo, on initialise le lecteur immédiatement
    if (widget.splitData['type'] == 'video' && widget.splitData['mediaUrl'] != null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.splitData['mediaUrl']))
        ..initialize().then((_) {
          setState(() {
            _isPlayerInitialized = true;
          });
          _videoController?.setLooping(true);
          _videoController?.play(); // Lecture automatique au focus
        });
    }
  }

  @override
  void dispose() {
    // CRITIQUE : Libérer la mémoire du téléphone quand l'utilisateur swipe pour éviter les crashs
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasVoted = widget.splitData['userVoted'] != null;
    final int totalVotes = widget.splitData['votesA'] + widget.splitData['votesB'];
    
    final int percentA = totalVotes > 0 ? ((widget.splitData['votesA'] / totalVotes) * 100).round() : 0;
    final int percentB = totalVotes > 0 ? ((widget.splitData['votesB'] / totalVotes) * 100).round() : 0;

    return Stack(
      children: [
        /// arrière-plan 1 : LE MÉDIA DE L'UTILISATEUR (Image ou Vidéo plein écran)
        if (widget.splitData['type'] == 'image' && widget.splitData['mediaUrl'] != null)
          Positioned.fill(
            child: Image.network(
              widget.splitData['mediaUrl'],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)));
              },
            ),
          ),
          
        if (widget.splitData['type'] == 'video' && _isPlayerInitialized)
          Positioned.fill(
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController?.value.size.width ?? 100,
                  height: _videoController?.value.size.height ?? 100,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          ),

        /// arrière-plan 2 : Calque sombre pour garantir la lisibilité du texte par-dessus les photos/vidéos
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),

        /// INTERFACE DE SÉLECTION (Le Duel)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // Aligné vers le bas style TikTok
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                
                /// QUESTION DU SPLIT
                 /// QUESTION DU SPLIT
Text(
  widget.splitData['question'].toString().toUpperCase(),
  style: TextStyle( // <--- ICI : On a enlevé le "const"
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w900 ,// <--- Plus aucune vague rouge ici
    shadows: const [ // <--- Tu peux rajouter const ici si tu veux optimiser les ombres
      Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2)),
    ],
  ), // TextStyle
  textAlign: TextAlign.center,
), // Text
const SizedBox(height: 30),
            

                /// BOUTONS BINAIRES
                Row(
                  children: [
                    // OPTION A (Néon Bleu)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => {if (!hasVoted) widget.onVote('A')},
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 120,
                          decoration: BoxDecoration(
                            color: widget.splitData['userVoted'] == 'A' 
                                ? const Color(0xFF00D2FF).withOpacity(0.4) 
                                : Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00D2FF),
                              width: widget.splitData['userVoted'] == 'A' ? 3 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            hasVoted ? "$percentA%\n${widget.splitData['optionA']}" : widget.splitData['optionA'],
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16, 
                              fontWeight: hasVoted ? FontWeight.bold : FontWeight.normal
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // OPTION B (Néon Violet)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => {if (!hasVoted) widget.onVote('B')},
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 120,
                          decoration: BoxDecoration(
                            color: widget.splitData['userVoted'] == 'B' 
                                ? const Color(0xFF9D00FF).withOpacity(0.4) 
                                : Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF9D00FF),
                              width: widget.splitData['userVoted'] == 'B' ? 3 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            hasVoted ? "$percentB%\n${widget.splitData['optionB']}" : widget.splitData['optionB'],
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16, 
                              fontWeight: hasVoted ? FontWeight.bold : FontWeight.normal
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                /// COMPTEUR HUMAIN
                Text(
                  "$totalVotes avis exprimés",
                  style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}