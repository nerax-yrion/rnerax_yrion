import 'package:flutter/material.dart';
// N'oublie pas d'importer tes deux nouveaux fichiers ici !
import 'message_vocale/enregistreur_audio_technique.dart';
import 'message_vocale/capsule_audio_design.dart';

class ZoneSaisieMessage extends StatefulWidget {
  const ZoneSaisieMessage({super.key});

  @override
  State<ZoneSaisieMessage> createState() => _ZoneSaisieMessageState();
}

class _ZoneSaisieMessageState extends State<ZoneSaisieMessage> {
  // 1. Déclaration de ton contrôleur technique (Placé au niveau des variables d'état)
  final EnregistreurAudioTechnique _monAudioControleur = EnregistreurAudioTechnique();
  
  bool _estEnTrainDEnregistrer = false;
  String _chronoAffichage = "00:00";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: const Color(0xFF0E0B1E), // Fond sombre accordé à ton thème YO
      child: SafeArea(
        child: _estEnTrainDEnregistrer 
          ? _construireInterfaceVocal() // Si on enregistre, on bascule sur ta Capsule Cyber
          : _construireInterfaceSaisieClassique(), // Sinon, barre de texte normale
      ),
    );
  }

  /// 🎙️ L'INTERFACE QUAND LE VOCAL EST ACTIF
  Widget _construireInterfaceVocal() {
    return CapsuleAudioDesign(
      progressionLecture: 0.0, // Reste à 0 pendant l'enregistrement (ou branché sur le volume)
      estEnTrainDeLire: true,
      formatChrono: _chronoAffichage,
      onBoutonActionPressed: () async {
        // En appuyant sur le bouton central dégradé, on valide et on envoie !
        String? cheminAudio = await _monAudioControleur.finaliserEnregistrement();
        if (cheminAudio != null) {
          // Logique pour envoyer le fichier .m4a sur ton serveur/Firebase
          debugPrint("Audio HD prêt à l'envoi : $cheminAudio");
        }
        setState(() => _estEnTrainDEnregistrer = false);
      },
      onAnnulerEnvoi: () async {
        // L'utilisateur a cliqué sur la petite poubelle YO !
        await _monAudioControleur.annulerEtDetruireAudio();
        // On quitte l'interface de d'enregistrement, le fichier est détruit
        setState(() => _estEnTrainDEnregistrer = false);
      },
    );
  }

  /// ⌨️ L'INTERFACE CLASSIQUE (CHAMP DE TEXTE + BOUTON MICRO)
  Widget _construireInterfaceSaisieClassique() {
    return Row(
      children: [
        const Expanded(
          child: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Message...",
              hintStyle: TextStyle(color: Colors.white30),
              border: InputBorder.none,
            ),
          ),
        ),
        // Le bouton micro qui déclenche le mode vocal pro de YO
        IconButton(
          icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF00D2FF)), // Bleu Cyan Néon
          onPressed: () async {
            // Quand l'utilisateur clique sur le micro :
            await _monAudioControleur.demarrerEnregistrement();
            setState(() {
              _estEnTrainDEnregistrer = true;
              _chronoAffichage = "00:00"; // Réinitialise le chrono de capture
            });
          },
        ),
      ],
    );
  }
}



// zonz ou il les le carre pour ecrire 
// sse fichier comporte encore plei de probleme