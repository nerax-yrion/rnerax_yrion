class ChatUser {
  final String id;
  final String username;
  final String pseudo;
  final String? avatarUrl;
  final bool enLigne;
  // 🛡️ Le nouveau champ pour le système de compte public/privé
  final String statutConfidentialite;

  ChatUser({
    required this.id,
    required this.username,
    required this.pseudo,
    this.avatarUrl,
    required this.enLigne,
    // 🛡️ Initialisé à 'public' par défaut si non spécifié
    this.statutConfidentialite = 'public',
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      pseudo: json['pseudo'] ?? '',
      avatarUrl: json['avatar_url'],
      enLigne: json['en_ligne'] ?? false,
      // 🛡️ Récupération sécurisée depuis le JSON de ton API
      statutConfidentialite: json['statut_confidentialite'] ?? 'public',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'pseudo': pseudo,
    'avatar_url': avatarUrl,
    'en_ligne': enLigne,
    // 🛡️ Inclus dans le JSON pour les requêtes de mise à jour
    'statut_confidentialite': statutConfidentialite,
  };
}