// notification_model.dart

enum PhaseParcours { initialisation, encodage, dispatch, livraison, activation }
enum ActionNotification { like, reaction, commentaire, follow, message }

class ActeurNotif {
  final String userId;
  final String username;
  final String? profileImageUrl;

  ActeurNotif({
    required this.userId,
    required this.username,
    this.profileImageUrl,
  });

  factory ActeurNotif.fromJson(Map<String, dynamic> json) {
    return ActeurNotif(
      userId: json['user_id'],
      username: json['username'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}

class NotificationQuantique {
  final String id;
  final ActionNotification action;
  final PhaseParcours phase;
  final ActeurNotif acteur;
  final String messageApercu;
  final String? cibleId;

  NotificationQuantique({
    required this.id,
    required this.action,
    required this.phase,
    required this.acteur,
    required this.messageApercu,
    this.cibleId,
  });

  factory NotificationQuantique.fromJson(Map<String, dynamic> json) {
    return NotificationQuantique(
      id: json['notification_id'],
      action: ActionNotification.values.byName(json['action']),
      phase: PhaseParcours.values.byName(json['phase']),
      acteur: ActeurNotif.fromJson(json['acteur']),
      messageApercu: json['message_apercu'],
      cibleId: json['cible_id'],
    );
  }
}