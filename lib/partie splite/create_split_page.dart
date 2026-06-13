import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // <--- AJOUT : Pour gérer les vrais médias

class CreateSplitPage extends StatefulWidget {
  const CreateSplitPage({super.key});

  @override
  State<CreateSplitPage> createState() => _CreateSplitPageState();
}

class _CreateSplitPageState extends State<CreateSplitPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // <--- AJOUT : Instance du sélecteur d'images
  
  File? _mediaFileA;
  File? _mediaFileB;

  // Fonction pour sélectionner une image pour l'option A ou B
  Future<void> _pickImage(bool isOptionA) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimisation du poids pour le serveur Rust
      );
      
      if (pickedFile != null) {
        setState(() {
          if (isOptionA) {
            _mediaFileA = File(pickedFile.path);
          } else {
            _mediaFileB = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la sélection de l'image: $e");
    }
  }

  void _submitSplit() {
    // Validation stricte : Tout doit être rempli (Texte + Images) pour éviter les corruptions SQL
    if (_questionController.text.trim().isEmpty || 
        _optionAController.text.trim().isEmpty || 
        _optionBController.text.trim().isEmpty ||
        _mediaFileA == null ||
        _mediaFileB == null) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text('Complète le duel ! Il faut une question, deux options et deux images.'),
        ),
      );
      return;
    }

    // TODO: Connecter ici ton appel API multipart vers FastAPI/Rust
    // Envoi de la question, option A, option B + les fichiers _mediaFileA et _mediaFileB
    
    Navigator.pop(context); // Ferme l'overlay après publication
  }

  @override
  void dispose() {
    // Nettoyage de la mémoire pour éviter les fuites de performances
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // S'adapte dynamiquement pour éviter que le clavier masque les boutons
      height: MediaQuery.of(context).size.height * 0.85 + bottomInset,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0C24),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 24 + bottomInset, // Remonte les widgets quand le clavier sort
      ),
      child: SingleChildScrollView( // Évite les débordements (Overflow) sur les petits écrans
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre de drag supérieure
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'LANCE TON DUEL',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Champ Question Épuré
            TextField(
              controller: _questionController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              maxLength: 85,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Ta question clivante... (Ex: iPhone ou Android ?)",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF171334),
                counterStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Bloc des deux choix interactifs côte à côte
            Row(
              children: [
                // BLOC CHOIX A (Néon Bleu)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(true), // Sélection de l'image au clic
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171334),
                        borderRadius: BorderRadius.circular(20),
                        image: _mediaFileA != null 
                            ? DecorationImage(image: FileImage(_mediaFileA!), fit: BoxFit.cover)
                            : null, // Affiche l'image sélectionnée en fond
                        border: Border.all(
                          color: _mediaFileA != null ? const Color(0xFF00D2FF) : const Color(0xFF00D2FF).withOpacity(0.2), 
                          width: _mediaFileA != null ? 3 : 1.5,
                        ),
                        boxShadow: _mediaFileA != null ? [
                          BoxShadow(color: const Color(0xFF00D2FF).withOpacity(0.3), blurRadius: 12, spreadRadius: 1)
                        ] : [],
                      ),
                      child: Container(
                        // Overlay sombre pour garder le texte lisible si une image est présente
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.black.withOpacity(_mediaFileA != null ? 0.4 : 0.0),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_mediaFileA == null)
                              const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF00D2FF), size: 40),
                            const Spacer(),
                            TextField(
                              controller: _optionAController,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 15,
                              decoration: const InputDecoration(
                                hintText: "Option A",
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                                counterText: "", // Masque le compteur moche
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // BLOC CHOIX B (Néon Violet)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171334),
                        borderRadius: BorderRadius.circular(20),
                        image: _mediaFileB != null 
                            ? DecorationImage(image: FileImage(_mediaFileB!), fit: BoxFit.cover)
                            : null,
                        border: Border.all(
                          color: _mediaFileB != null ? const Color(0xFF9D00FF) : const Color(0xFF9D00FF).withOpacity(0.2), 
                          width: _mediaFileB != null ? 3 : 1.5,
                        ),
                        boxShadow: _mediaFileB != null ? [
                          BoxShadow(color: const Color(0xFF9D00FF).withOpacity(0.3), blurRadius: 12, spreadRadius: 1)
                        ] : [],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.black.withOpacity(_mediaFileB != null ? 0.4 : 0.0),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_mediaFileB == null)
                              const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF9D00FF), size: 40),
                            const Spacer(),
                            TextField(
                              controller: _optionBController,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 15,
                              decoration: const InputDecoration(
                                hintText: "Option B",
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                                counterText: "",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),

            // Bouton de Soumission Premium Électrique
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9D00FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 8,
                shadowColor: const Color(0xFF9D00FF).withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _submitSplit,
              child: const Text(
                'PROPAGER LE SPLIT',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}