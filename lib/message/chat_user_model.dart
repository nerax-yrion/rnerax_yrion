class ChatUser {
  final String id;
  final String username;
  final String pseudo;
  final String? avatarUrl;
  final bool enLigne;

  ChatUser({
    required this.id,
    required this.username,
    required this.pseudo,
    this.avatarUrl,
    required this.enLigne,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      pseudo: json['pseudo'] ?? '',
      avatarUrl: json['avatar_url'],
      enLigne: json['en_ligne'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'pseudo': pseudo,
    'avatar_url': avatarUrl,
    'en_ligne': enLigne,
  };
}