import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../message/chat_user_model.dart';
import '../profil/profil_data.dart'; // Importation de ton fichier profil local

class ChatService {
  final String _baseUrl = "https://ton-api-render.com/api";
  final String _wsUrl = "wss://ton-api-render.com/ws";

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();

  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  /// 🌐 Ouvre le canal WebSocket temps réel
  void connecterWebSocket() {
    if (_channel != null) return;

    final uri = Uri.parse("$_wsUrl?userId=${ProfilData.userId}");
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (donnees) {
        try {
          final Map<String, dynamic> messageJson = jsonDecode(donnees);
          _messageStreamController.add(messageJson);
        } catch (e) {
          print("Erreur WS: $e");
        }
      },
      onDone: () {
        _channel = null;
        Future.delayed(const Duration(seconds: 3), () => connecterWebSocket());
      },
      onError: (err) {
        _channel = null;
      }
    );
  }

  /// 📤 Propale un paquet de message instantanément
  void envoyerMessageTempsReel({required String destinataireId, required String texte}) {
    if (_channel == null) connecterWebSocket();

    final paquet = {
      "sender_id": ProfilData.userId,
      "receiver_id": destinataireId,
      "text": texte,
      "timestamp": DateTime.now().toIso8601String(),
    };

    _channel?.sink.add(jsonEncode(paquet));
    _messageStreamController.add(paquet);
  }

  Stream<Map<String, dynamic>> get fluxMessages => _messageStreamController.stream;

  /// 👥 Récupère l'ensemble des contacts actifs depuis Neon SQL
  Future<List<ChatUser>> recupererDiscussionsActuelles() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/messages/conversations/${ProfilData.userId}'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ChatUser.fromJson(item)).toList();
      }
    } catch (e) {
      print("Erreur HTTP: $e");
    }
    return [];
  }

  /// 💬 Charge l'historique complet d'un salon
  Future<List<Map<String, dynamic>>> recupererHistorique(String destinataireId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/messages/history/${ProfilData.userId}/$destinataireId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {}
    return [];
  }

  void deconnexion() {
    _channel?.sink.close();
    _channel = null;
  }
}