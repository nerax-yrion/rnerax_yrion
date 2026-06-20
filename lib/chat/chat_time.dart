/// ⏱️ CALCULATEUR DE TEMPS CYBER
/// Transforme les dates brutes du serveur en texte lisible sous les bulles.
class ChatTimeParser {
  static String recupererHeureEtDate(Map<String, dynamic> msg) {
    if (msg["timestamp"] == null) return "";
    
    final DateTime dateMessage = DateTime.parse(msg["timestamp"].toString()).toLocal();
    final DateTime maintenant = DateTime.now().toLocal();
    
    final String minute = dateMessage.minute < 10 ? "0${dateMessage.minute}" : "${dateMessage.minute}";
    final String heure = "${dateMessage.hour}:$minute";

    // Si c'est aujourd'hui : juste l'heure (ex: 14:05)
    if (dateMessage.day == maintenant.day && 
        dateMessage.month == maintenant.month && 
        dateMessage.year == maintenant.year) {
      return heure;
    }
    
    // Sinon : Date + Heure (ex: 19 Juin, 14:05)
    final desMois = ["Janv.", "Févr.", "Mars", "Avril", "Mai", "Juin", "Juill.", "Août", "Sept.", "Oct.", "Nov.", "Déc."];
    return "${dateMessage.day} ${desMois[dateMessage.month - 1]}, $heure";
  }
}

// se fichier resposable ndaficher la date est heure dans le chat