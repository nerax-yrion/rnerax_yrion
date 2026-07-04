// notifications_screen.dart

import 'package:flutter/material.dart';
import 'yrion_socket_service.dart';
import 'notification_model.dart';
import 'quantum_notif_widget.dart';

class NotificationsScreen extends StatefulWidget {
  final String userIdToken; // Le token ou ID de l'utilisateur connecté

  const NotificationsScreen({Key? key, required this.userIdToken}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final YrionSocketService _socketService = YrionSocketService();
  final List<NotificationQuantique> _listeNotifications = [];

  @override
  void dispose() {
    _socketService.deconnecter(); // On coupe proprement la connexion quand on quitte l'écran
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fond sombre pro pour l'empire Yrion
      appBar: AppBar(
        title: const Text("Flux Quantique", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<NotificationQuantique>(
        stream: _socketService.connecterEtEcouter(widget.userIdToken),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de connexion au serveur", style: TextStyle(color: Colors.red)));
          }

          if (snapshot.connectionState == ConnectionState.waiting && _listeNotifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          // Dès qu'une nouvelle notification arrive, on l'ajoute ou on met à jour sa phase
          if (snapshot.hasData && snapshot.data != null) {
            final nouvelleNotif = snapshot.data!;
            
            // On vérifie si la notification existe déjà dans la liste pour mettre à jour sa phase
            final index = _listeNotifications.indexWhere((n) => n.id == nouvelleNotif.id);
            
            if (index != -index && index >= 0) {
              _listeNotifications[index] = nouvelleNotif; // Mise à jour de la phase (ex: dispatch -> activation)
            } else if (nouvelleNotif.id != "error") {
              _listeNotifications.insert(0, nouvelleNotif); // Nouvelle notification en haut de la liste
            }
          }

          if (_listeNotifications.isEmpty) {
            return const Center(
              child: Text("Aucune notification pour le moment", style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: _listeNotifications.length,
            itemBuilder: (context, index) {
              return QuantumNotifWidget(notification: _listeNotifications[index]);
            },
          );
        },
      ),
    );
  }
}