import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // requis pour l'envoi Multipart vers le serveur Rust
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'profil_data.dart';

class PhotoProfilPage extends StatefulWidget {
  const PhotoProfilPage({super.key});

  @override
  State<PhotoProfilPage> createState() => _PhotoProfilPageState();
}

class _PhotoProfilPageState extends State<PhotoProfilPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageSelectionnee;
  bool _estEnCoursDeChargement = false; // Bloque l'interface pendant l'upload réseau

  Future<void> _recupererImage(ImageSource source) async {
    try {
      final XFile? fichierSelectionne = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85, // Compression légère pour respecter les limites du serveur
      );

      if (fichierSelectionne != null) {
        setState(() {
          _imageSelectionnee = File(fichierSelectionne.path);
        });
      }
    } catch (e) {
      debugPrint("Erreur d'accès matériel : $e");
    }
  }

  /// 🚀 ENVOI MULTIPART VERS LE SERVEUR RUST ET ENREGISTREMENT LOCAL
  Future<void> _sauvegarderEtQuitter() async {
    if (_imageSelectionnee == null || _estEnCoursDeChargement) return;

    setState(() {
      _estEnCoursDeChargement = true;
    });

    try {
      // 🌐 URL de ton endpoint Axum dédié aux avatars
      final url = Uri.parse('http://10.0.2.2:8080/remplacer_avatar'); // 10.0.2.2 = localhost sur émulateur Android

      // 📦 Préparation de la requête multipart (format requis pour envoyer des fichiers physiques)
      final requete = http.MultipartRequest('POST', url);

      // 🔑 Ajout des champs textuels nécessaires pour que le serveur sache à qui appartient l'image
      requete.fields['email'] = ProfilData.email;

      // 🖼️ Ajout du fichier image réel
      final fluxFichier = await http.MultipartFile.fromPath(
        'avatar', // Cette clé DOIT correspondre au champ attendu par ton extracteur Multipart côté Rust
        _imageSelectionnee!.path,
      );
      requete.files.add(fluxFichier);

      // 🛫 Expédition du paquet vers le serveur
      final reponseEnvoi = await requete.send();
      final reponse = await http.Response.fromStream(reponseEnvoi);

      // 🚦 Analyse de la réponse du serveur Axum
      if (reponse.statusCode == 200) {
        // Le serveur a bien enregistré le fichier, on applique le changement dans le cache local
        ProfilData.mettreAJourAvatar(_imageSelectionnee!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: YrionTheme.cyanNeon,
            content: Text(
              "CAPTEUR VISUEL SYNCHRONISÉ", 
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );

        Navigator.pop(context); // Retour
      } else {
        _afficherErreur("ERREUR SERVEUR : CODE ${reponse.statusCode}");
      }
    } catch (e) {
      _afficherErreur("ERREUR RÉSEAU : TRANSMISSION DE L'IMAGE IMPOSSIBLE");
    } finally {
      if (mounted) {
        setState(() {
          _estEnCoursDeChargement = false;
        });
      }
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: YrionTheme.magentaNeon,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sélection de la source de l'image pour le grand aperçu
    ImageProvider? imageAffichee;
    if (_imageSelectionnee != null) {
      imageAffichee = FileImage(_imageSelectionnee!);
    } else if (ProfilData.avatarFichierLocal != null) {
      imageAffichee = FileImage(ProfilData.avatarFichierLocal!);
    }

    return Scaffold(
      backgroundColor: YrionTheme.spaceDeep,
      body: SafeArea(
        child: Column(
          children: [
            const CyberHeader(title: "CAPTEUR VISUEL", showBackButton: true),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "MODIFIER LE LOGO D'IDENTITÉ",
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 40),

                    /// 👤 APERÇU SÉCURISÉ
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [YrionTheme.cyanNeon, YrionTheme.magentaNeon]),
                        boxShadow: [
                          BoxShadow(color: YrionTheme.cyanNeon, blurRadius: 20, spreadRadius: 2)
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: YrionTheme.cardBackground,
                        backgroundImage: imageAffichee,
                        child: imageAffichee == null
                            ? Text(
                                ProfilData.obtenirInitiale(),
                                style: const TextStyle(color: YrionTheme.cyanNeon, fontSize: 54, fontWeight: FontWeight.w900),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 50),

                    GestureDetector(
                      onTap: _estEnCoursDeChargement ? null : () => _afficherMenuChoix(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: YrionTheme.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: YrionTheme.cyanNeon.withOpacity(0.6)),
                        ),
                        child: const Center(
                          child: Text(
                            "CHOISIR UNE SOURCE",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_imageSelectionnee != null)
                      GestureDetector(
                        onTap: _sauvegarderEtQuitter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: _estEnCoursDeChargement
                                ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
                                : const LinearGradient(colors: [YrionTheme.cyanNeon, YrionTheme.magentaNeon]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: _estEnCoursDeChargement
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "APPLIQUER LA NOUVELLE IMAGE",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _afficherMenuChoix(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: YrionTheme.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: YrionTheme.borderNeon, borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: YrionTheme.cyanNeon),
                  title: const Text("Ouvrir la Galerie", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _recupererImage(ImageSource.gallery);
                  },
                ),
                Divider(color: YrionTheme.borderNeon.withOpacity(0.4)),
                ListTile(
                  leading: const Icon(Icons.camera_enhance_rounded, color: YrionTheme.magentaNeon),
                  title: const Text("Déclencher l'Appareil Photo", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _recupererImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}