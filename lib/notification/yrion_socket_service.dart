import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'notification_model.dart';

class YrionSocketService {
  WebSocketChannel? _channel;
  StreamController<NotificationQuantique>? _controller;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer; // 🫀 Le pacemaker du flux quantique
  bool _estDeconnecteVolontairement = false;
  
  // ⏱️ Gestion dynamique du délai pour économiser la batterie
  int _delaiReconnexionSecondes = 2;

  // 🛰️ URL de ton serveur de chat principal Yrion en production sur Render
  final String _urlServeur = "wss://backend-chat-principal-yrion.onrender.com/yrion_univers";

  // 📡 Initialisation et connexion au réseau d'Yrion avec reconnexion automatique
  Stream<NotificationQuantique> connecterEtEcouter(String tokenUtilisateur) {
    // Fermeture de l'ancien controller s'il existait pour éviter les fuites de mémoire
    _controller?.close();
    _annulerHeartbeat();
    
    _controller = StreamController<NotificationQuantique>.broadcast();
    _estDeconnecteVolontairement = false;
    _delaiReconnexionSecondes = 2; // Réinitialisation du délai

    _etablirConnexion(tokenUtilisateur);

    return _controller!.stream;
  }

  void _etablirConnexion(String tokenUtilisateur) {
    if (_estDeconnecteVolontairement) return;

    // 🛠️ SÉCURITÉ CRITIQUE : On nettoie toujours proprement l'ancien canal et les timers avant d'en ouvrir un nouveau
    _annulerHeartbeat();
    try {
      _channel?.sink.close();
    } catch (_) {}

    print("[YRION CORE] Tentative de liaison quantique (Délai : $_delaiReconnexionSecondes s)...");

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse("$_urlServeur?token=$tokenUtilisateur"),
      );

      // 🫀 DÉCLENCHEMENT DU HEARTBEAT : On commence à envoyer des pings réguliers
      _demarrerHeartbeat(tokenUtilisateur);

      _channel!.stream.listen(
        (evenement) {
          // Si on reçoit un message réussi (y compris le pong du serveur), le réseau est stable ! On remet le délai à 2s.
          _delaiReconnexionSecondes = 2;
          
          // Si c'est juste un pong de maintien de vie, on ignore le décodage JSON
          if (evenement == "pong") return;
          
          try {
            final Map<String, dynamic> jsonBrut = jsonDecode(evenement);
            final notif = NotificationQuantique.fromJson(jsonBrut);
            if (_controller != null && !_controller!.isClosed) {
              _controller!.add(notif);
            }
          } catch (e) {
            print("[ERR CORE] Échec du décodage du signal : $e");
            if (_controller != null && !_controller!.isClosed) {
              _controller!.add(NotificationQuantique(
                id: "error",
                action: ActionNotification.message,
                phase: PhaseParcours.initialisation,
                acteur: ActeurNotif(userId: "0", username: "Système"),
                messageApercu: "Erreur de synchronisation du paquet.",
              ));
            }
          }
        },
        onError: (erreur) {
          print("[YRION CORE] Erreur réseau détectée : $erreur. Planification du saut...");
          _planifierReconnexion(tokenUtilisateur);
        },
        onDone: () {
          print("[YRION CORE] Le flux s'est interrompu. Reconnexion en cours...");
          _planifierReconnexion(tokenUtilisateur);
        },
      );
    } catch (e) {
      print("[YRION CORE] Impossible de joindre la passerelle : $e");
      _planifierReconnexion(tokenUtilisateur);
    }
  }

  // 🫀 Envoie un Ping toutes les 20 secondes pour maintenir Render éveillé et vérifier la ligne
  void _demarrerHeartbeat(String tokenUtilisateur) {
    _heartbeatTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      try {
        if (_channel != null) {
          _channel!.sink.add("ping");
        }
      } catch (e) {
        print("[YRION CORE] Échec du Heartbeat, le canal est mort en douce. Reconnexion...");
        _planifierReconnexion(tokenUtilisateur);
      }
    });
  }

  void _annulerHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _planifierReconnexion(String tokenUtilisateur) {
    _annulerHeartbeat();
    _reconnectTimer?.cancel();
    if (_estDeconnecteVolontairement) return;

    _reconnectTimer = Timer(Duration(seconds: _delaiReconnexionSecondes), () {
      _etablirConnexion(tokenUtilisateur);
      
      // 🚀 BACKOFF INTELLIGENT : On augmente le délai pour réveiller Render sans détruire la batterie du smartphone
      if (_delaiReconnexionSecondes < 15) {
        if (_delaiReconnexionSecondes == 2) {
          _delaiReconnexionSecondes = 5;
        } else if (_delaiReconnexionSecondes == 5) {
          _delaiReconnexionSecondes = 10;
        } else {
          _delaiReconnexionSecondes = 15;
        }
      }
    });
  }

  // 🔌 Fermeture propre de la connexion pour préserver la batterie du téléphone
  void deconnecter() {
    _estDeconnecteVolontairement = true;
    _reconnectTimer?.cancel();
    _annulerHeartbeat();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _controller?.close();
    print("[YRION CORE] Canal déconnecté proprement. Système en veille.");
  }
}