// yrion_socket_service.dart

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'notification_model.dart';

class YrionSocketService {
  WebSocketChannel? _channel;
  
  // Remplacer par l'URL finale de ton serveur de notifications Render / Localhost
  final String _urlServeur = "wss://backend-recher-user-yrion.onrender.com/ws/notifications";

  // 📡 Initialisation et connexion au réseau d'Yrion
  Stream<NotificationQuantique> connecterEtEcouter(String tokenUtilisateur) {
    // On passe le token ou l'ID dans les en-têtes ou paramètres pour sécuriser le flux
    _channel = WebSocketChannel.connect(
      Uri.parse("$_urlServeur?token=$tokenUtilisateur"),
    );

    print("[YRION CORE] Connexion établie avec le canal quantique.");

    // On transforme le flux de texte brut en objets NotificationQuantique dynamiques
    return _channel!.stream.map((evenement) {
      try {
        final Map<String, dynamic> jsonBrut = jsonDecode(evenement);
        return NotificationQuantique.fromJson(jsonBrut);
      } catch (e) {
        print("[ERR CORE] Échec du décodage du signal : $e");
        // En cas d'erreur, on génère un paquet de secours pour éviter le crash de Flutter
        return NotificationQuantique(
          id: "error",
          action: ActionNotification.message,
          phase: PhaseParcours.initialisation,
          acteur: ActeurNotif(userId: "0", username: "Système"),
          messageApercu: "Erreur de synchronisation du paquet.",
        );
      }
    });
  }

  // 🔌 Fermeture propre de la connexion pour préserver la batterie du téléphone
  void deconnecter() {
    _channel?.sink.close();
    print("[YRION CORE] Canal déconnecté proprement.");
  }
}