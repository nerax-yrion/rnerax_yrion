import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum EtatSignalOrbital { stable, instable, perdu }

/// 📡 **LE CAPTEUR DE FLUX QUANTIQUE AVEC SÉCURITÉ ANTI-CLIGNOTEMENT**
/// Surveille le matériel réseau et filtre les micro-instabilités invisibles.
class GestionnaireSignalSpatial {
  static final GestionnaireSignalSpatial _instance = GestionnaireSignalSpatial._internal();
  factory GestionnaireSignalSpatial() => _instance;
  GestionnaireSignalSpatial._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<EtatSignalOrbital> _fluxSignalController = StreamController<EtatSignalOrbital>.broadcast();
  
  Timer? _timerDeSecurite;

  Stream<EtatSignalOrbital> get fluxSignal => _fluxSignalController.stream;

  /// Démarre l'écoute active des pannes de réseau
  void initialiserSurveillance() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> resultats) {
      
      if (resultats.isEmpty || resultats.contains(ConnectivityResult.none)) {
        // 🛑 Signal potentiellement perdu : On attend 2 secondes avant d'alarmer l'UI
        _timerDeSecurite?.cancel();
        _timerDeSecurite = Timer(const Duration(seconds: 2), () {
          _fluxSignalController.add(EtatSignalOrbital.perdu);
        });

      } else {
        // 🟢 Le réseau est excellent : On annule le compte à rebours immédiatement
        _timerDeSecurite?.cancel();
        _fluxSignalController.add(EtatSignalOrbital.stable);
      }
    });
  }

  /// Libère les ressources du flux à la fermeture de l'application
  void fermerFlux() {
    _timerDeSecurite?.cancel();
    _fluxSignalController.close();
  }
}