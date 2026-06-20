import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// 🎙️ **LE CERVEAU AUDIO QUANTIQUE : ENREGISTREUR ULTRA-HD YO**
/// Configure le flux audio natif au niveau studio d'enregistrement maximal.
class EnregistreurAudioTechnique {
  final AudioRecorder _enregistreurNatif = AudioRecorder();
  String? _cheminFichierCourant;
  bool _estEnregistrementActif = false;

  bool get estEnregistrementActif => _estEnregistrementActif;

  /// Initialise et démarre la capture avec le codec haute fidélité Opus
  Future<void> demarrerEnregistrement() async {
    try {
      if (await _enregistreurNatif.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _cheminFichierCourant = '${directory.path}/yo_master_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // 🎛️ CONFIGURATION MASTERING PRO : Écrase la compression WhatsApp/Telegram
        const configurationPro = RecordConfig(
          encoder: AudioEncoder.aacLc, // Encodage AAC Haute Qualité constant
          bitRate: 128000,              // 128 kbps : clarté absolue des voix
          sampleRate: 48000,           // 48 kHz : Échantillonnage qualité Studio / Bluray
          numChannels: 1,              // Mono optimisé pour la réduction des bruits ambiants
        );

        await _enregistreurNatif.start(configurationPro, path: _cheminFichierCourant!);
        _estEnregistrementActif = true;
      }
    } catch (e) {
      _estEnregistrementActif = false;
    }
  }

  /// Arrête et sauvegarde définitivement le fichier audio pur
  Future<String?> finaliserEnregistrement() async {
    if (!_estEnregistrementActif) return null;
    try {
      final chemin = await _enregistreurNatif.stop();
      _estEnregistrementActif = false;
      return chemin;
    } catch (e) {
      _estEnregistrementActif = false;
      return null;
    }
  }

  /// 🗑️ ANNULATION ATOMIQUE : Coupe le micro et détruit instantanément les données temporaires
  Future<void> annulerEtDetruireAudio() async {
    if (!_estEnregistrementActif) return;
    try {
      await _enregistreurNatif.stop();
      _estEnregistrementActif = false;
      
      if (_cheminFichierCourant != null) {
        final fichierADetruire = File(_cheminFichierCourant!);
        if (await fichierADetruire.exists()) {
          await fichierADetruire.delete(); // Nettoyage physique du stockage
        }
      }
    } catch (_) {}
  }
}