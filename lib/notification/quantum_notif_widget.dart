// quantum_notif_widget.dart

import 'package:flutter/material.dart';
import 'notification_model.dart';

class QuantumNotifWidget extends StatelessWidget {
  final NotificationQuantique notification;

  const QuantumNotifWidget({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut, // Animation plus dynamique pour l'empire Yrion
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4), // Fond sombre pro
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: notification.phase == PhaseParcours.activation 
              ? Colors.cyanAccent.withOpacity(0.6) // Halo de succès
              : Colors.white10,
          width: 1.5,
        ),
        boxShadow: [
          if (notification.phase == PhaseParcours.activation)
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            )
        ],
      ),
      child: Row(
        children: [
          // 🛰️ ZONE LOGO YRION / PHOTO USER
          SizedBox(
            width: 56,
            height: 56,
            child: _construireVisuelDynamique(notification),
          ),
          const SizedBox(width: 16),
          
          // 📝 INFOS DYNAMIQUES (Pseudo & Message de la DB)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.acteur.username, // Pseudo de l'expéditeur
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, 
                    fontSize: 16,
                    letterSpacing: 0.5
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    notification.phase == PhaseParcours.activation 
                        ? notification.messageApercu // Message final (ex: "Liked your story")
                        : "Traitement par Yrion Core...", // Message d'attente
                    key: ValueKey(notification.phase),
                    style: TextStyle(
                      color: notification.phase == PhaseParcours.activation 
                          ? Colors.grey[300] 
                          : Colors.cyanAccent.withOpacity(0.5), 
                      fontSize: 13
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 LOGIQUE DU VISUEL UNIQUE (Ton Logo -> Photo User)
  Widget _construireVisuelDynamique(NotificationQuantique notif) {
    // Si la notification n'est pas encore activée, on montre la puissance d'Yrion
    if (notif.phase != PhaseParcours.activation) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Animation de chargement circulaire autour de ton logo
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
          ),
          // Ton logo image_utile.png au centre
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/image_utile.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    }

    // 🎉 PHASE ACTIVATION : On affiche la vraie photo de l'user qui a déclenché la notif
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.cyanAccent, width: 1),
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white10,
        // Récupération dynamique de la photo de profil
        backgroundImage: notif.acteur.profileImageUrl != null 
            ? NetworkImage(notif.acteur.profileImageUrl!) 
            : null,
        child: notif.acteur.profileImageUrl == null 
            ? Text(
                notif.acteur.username.substring(0, 1).toUpperCase(), 
                style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)
              )
            : null,
      ),
    );
  }
}