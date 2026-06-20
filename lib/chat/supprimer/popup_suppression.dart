import 'package:flutter/material.dart';
// Importation des deux fichiers de logique
import 'supprimer_pour_soi.dart';
import 'supprimer_pour_tous.dart';

/// 🎨 **INTERFACE GRAPHIQUE : POPUP ALERT CYBER**
/// S'occupe exclusivement d'afficher le menu visuel à l'écran.
class PopupSuppression {
  
  static void afficher({
    required BuildContext context,
    required String messageId,
    required String salonId,
    required String userId,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131124),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏷️ Titre de la boîte
              const Padding(
                padding: EdgeInsets.only(left: 24, bottom: 20, right: 24),
                child: Text(
                  "Supprimer le message ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // 💥 Bouton : Supprimer pour nous deux (Destruction réseau)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text(
                  "Supprimer pour tout le monde",
                  style: TextStyle(
                    color: Color(0xFFE94057), 
                    fontSize: 15, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context); // Fermeture immédiate du popup (effet fluide)
                  
                  // Déclenchement de la fiche logique Réseau
                  await SupprimerPourTous.executer(
                    messageId: messageId,
                    salonId: salonId,
                    expediteurId: userId,
                  );
                },
              ),

              // 🗑️ Bouton : Supprimer pour moi (Nettoyage local)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text(
                  "Supprimer pour moi",
                  style: TextStyle(
                    color: Colors.white70, 
                    fontSize: 15, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context); // Fermeture immédiate du popup
                  
                  // Déclenchement de la fiche logique Locale
                  await SupprimerPourSoi.executer(
                    messageId: messageId,
                    userId: userId,
                  );
                },
              ),

              // ❌ Bouton : Fermer sans rien faire
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 10),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(
                        color: Colors.white38, 
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ); 
  }
}