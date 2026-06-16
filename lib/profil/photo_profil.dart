import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // ✂️ Moteur de traitement géométrique
import 'package:http/http.dart' as http;
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'profil_data.dart';

/// ====================================================================
/// YRION SOCIAL ECOSYSTEM : COMPOSANT FLUX MULTIPART HAUT RENDEMENT
/// PIPELINE : Acquisition -> Recadrage Circulaire Tactile -> Upload Cloud Render
/// INTÉGRATION : Validation en base Neon et rafraîchissement asynchrone
/// ====================================================================
class PhotoProfilPage extends StatefulWidget {
  const PhotoProfilPage({super.key});

  @override
  State<PhotoProfilPage> createState() => _PhotoProfilPageState();
}

class _PhotoProfilPageState extends State<PhotoProfilPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageSelectionnee;
  bool _estEnCoursDeChargement = false;

  /// 📸 ACQUISITION ET ISOLEMENT DU FLUX VISUEL MATÉRIEL
  Future<void> _recupererImage(ImageSource source) async {
    try {
      final XFile? fichierSelectionne = await _picker.pickImage(
        source: source,
        maxWidth: 1080, // Résolution augmentée pour maximiser la marge de zoom tactile
        maxHeight: 1080,
        imageQuality: 90, 
      );

      if (fichierSelectionne != null) {
        // Déclenchement automatique de la sur-couche de recadrage
        await _recadrerImageVisuelle(fichierSelectionne.path);
      }
    } catch (e) {
      _afficherErreur("ACCÈS IMPOSSIBLE AUX CAPTEURS MATÉRIELS DE L'APPAREIL");
    }
  }

  /// ✂️ MOTEUR DE RECADRAGE ET ALIGNEMENT DYNAMIQUE TACTILE
  Future<void> _recadrerImageVisuelle(String cheminFichier) async {
    try {
      final CroppedFile? fichierRecadre = await ImageCropper().cropImage(
        sourcePath: cheminFichier,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85, // Compression finale calibrée pour ton serveur Axum
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "AJUSTER LA MATRICE VISUELLE",
            toolbarColor: YrionTheme.spaceDeep,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true, // Force le format carré pour un rendu circulaire parfait
            activeControlsWidgetColor: YrionTheme.cyanNeon,
            backgroundColor: YrionTheme.spaceDeep,
            cropFrameColor: YrionTheme.cyanNeon,
            cropGridColor: YrionTheme.borderNeon.withOpacity(0.5),
          ),
          IOSUiSettings(
            title: "AJUSTER LE LOGO",
            cancelButtonTitle: "Annuler",
            doneButtonTitle: "Valider",
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (fichierRecadre != null) {
        setState(() {
          _imageSelectionnee = File(fichierRecadre.path);
        });
      }
    } catch (e) {
      _afficherErreur("ÉCHEC DU TRAITEMENT GÉOMÉTRIQUE DE L'IMAGE");
    }
  }

  /// 🚀 ENVOI STREAM MULTIPART VERS TON SERVEUR PRODUCTION RENDER
  Future<void> _sauvegarderEtQuitter() async {
    if (_imageSelectionnee == null || _estEnCoursDeChargement) return;

    setState(() {
      _estEnCoursDeChargement = true;
    });

    try {
      final url = Uri.parse('https://yrion-backend-profil.onrender.com/remplacer_avatar');
      final requete = http.MultipartRequest('POST', url);

      // Transmission des identifiants et clés de routage Neon
      requete.fields['user_id'] = ProfilData.userId;

      final fluxFichier = await http.MultipartFile.fromPath(
        'avatar', 
        _imageSelectionnee!.path,
      );
      requete.files.add(fluxFichier);

      final reponseEnvoi = await requete.send();
      final reponse = await http.Response.fromStream(reponseEnvoi);

      if (reponse.statusCode == 200) {
        ProfilData.mettreAJourAvatarLocal(_imageSelectionnee!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: YrionTheme.cyanNeon,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.gpp_good_rounded, color: Colors.black),
                SizedBox(width: 12),
                Text(
                  "MATRICE VISUELLE ENREGISTRÉE DANS LE CLUSTER", 
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        );

        Navigator.pop(context); 
      } else {
        _afficherErreur("REJET DU FICHIER PAR LE CLUSTER : CODE ${reponse.statusCode}");
      }
    } catch (e) {
      _afficherErreur("RUPTURE DE LIAISON : TRANSMISSION DE L'IMAGE IMPOSSIBLE");
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageAffichee;
    if (_imageSelectionnee != null) {
      imageAffichee = FileImage(_imageSelectionnee!);
    } else if (ProfilData.avatarFichierLocal != null) {
      imageAffichee = FileImage(ProfilData.avatarFichierLocal!);
    } else if (ProfilData.urlAvatarDistant != null && ProfilData.urlAvatarDistant!.isNotEmpty) {
      imageAffichee = NetworkImage(ProfilData.urlAvatarDistant!);
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
                      "CONFIGURER LA SIGNATURE VISUELLE",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 13, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 2.0,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 40),

                    /// 👤 APERÇU RADIAL CYBERPUNK
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [YrionTheme.cyanNeon, YrionTheme.magentaNeon],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: YrionTheme.cyanNeon, blurRadius: 25, spreadRadius: 1)
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: YrionTheme.spaceDeep, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 85,
                          backgroundColor: YrionTheme.cardBackground,
                          backgroundImage: imageAffichee,
                          child: imageAffichee == null
                              ? Text(
                                  ProfilData.obtenirInitiale(),
                                  style: const TextStyle(
                                    color: YrionTheme.cyanNeon, 
                                    fontSize: 58, 
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    GestureDetector(
                      onTap: _estEnCoursDeChargement ? null : () => _afficherMenuChoix(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: YrionTheme.cardBackground.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: YrionTheme.cyanNeon.withOpacity(0.5), width: 1.2),
                        ),
                        child: const Center(
                          child: Text(
                            "ACCÉDER AUX CAPTEURS D'IMAGES",
                            style: TextStyle(
                              color: YrionTheme.cyanNeon, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 1.0,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_imageSelectionnee != null)
                      GestureDetector(
                        onTap: _sauvegarderEtQuitter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: _estEnCoursDeChargement
                                ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
                                : const LinearGradient(colors: [YrionTheme.cyanNeon, YrionTheme.magentaNeon]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _estEnCoursDeChargement ? [] : [
                              BoxShadow(
                                color: YrionTheme.magentaNeon.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Center(
                            child: _estEnCoursDeChargement
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "DEPLOYER L'IMAGE EN PRODUCTION",
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
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
      backgroundColor: YrionTheme.spaceDeep,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(color: YrionTheme.borderNeon.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: YrionTheme.cyanNeon),
                  title: const Text("Ouvrir la Galerie Locale", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _recupererImage(ImageSource.gallery);
                  },
                ),
                Divider(color: YrionTheme.borderNeon.withOpacity(0.2)),
                ListTile(
                  leading: const Icon(Icons.camera_enhance_rounded, color: YrionTheme.magentaNeon),
                  title: const Text("Déclencher l'Appareil Matériel", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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