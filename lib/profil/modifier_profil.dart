import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'dart:convert'; // Requis pour encoder le JSON
import 'package:http/http.dart' as http; // Requis pour communiquer avec le backend Rust
import 'profil_data.dart';
import 'photo_profil.dart';

class ModifierProfilPage extends StatefulWidget {
  const ModifierProfilPage({super.key});

  @override
  State<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends State<ModifierProfilPage> {
  final _formKey = GlobalKey<FormState>();
  bool _estEnCoursDeChargement = false; // Pour éviter le double clic pendant la requête
  
  // Contrôleurs pour récupérer les textes saisis par l'utilisateur
  late TextEditingController _pseudoController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    // On pré-remplit les champs avec les données actuelles de l'utilisateur
    _pseudoController = TextEditingController(text: ProfilData.pseudo);
    _usernameController = TextEditingController(text: ProfilData.username);
    _bioController = TextEditingController(text: ProfilData.bio);
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// 🛰️ TRANSMISSION SYNCHRONISÉE VERS LE SERVEUR RUST ET ENREGISTREMENT LOCAL
  Future<void> _sauvegarderModifications() async {
    if (!_formKey.currentState!.validate() || _estEnCoursDeChargement) return;

    setState(() {
      _estEnCoursDeChargement = true;
    });

    // 🎯 Préparation des variables nettoyées
    final pseudoSaisi = _pseudoController.text.trim();
    final usernameSaisi = _usernameController.text.trim();
    final bioSaisie = _bioController.text.trim();

    try {
      // 🌐 Configuration de l'URL de ton serveur (remplace l'IP/port par ta configuration de déploiement)
      final url = Uri.parse('http://10.0.2.2:8080/actualiser_textes'); // 10.0.2.2 pointe vers localhost depuis l'émulateur Android

      // 📦 Corps de la requête au format attendu par la structure Rust 'RequeteMiseAJourProfil'
      final corpsRequete = jsonEncode({
        'email': ProfilData.email, // Ton backend a absolument besoin de l'email pour cibler la HashMap !
        'pseudo': pseudoSaisi,
        'nom_utilisateur': usernameSaisi, // Doit correspondre à la structure de modeles.rs
        'bio': bioSaisie,
      });

      // 🚀 Envoi de la requête réseau vers Rust
      final reponse = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: corpsRequete,
      );

      // 🚦 Analyse du code d'état HTTP retourné par Axum
      if (reponse.statusCode == 200) {
        // Le backend Rust a validé et enregistré, on met à jour le cache local
        ProfilData.mettreAJourIdentite(
          nouveauPseudo: pseudoSaisi,
          nouveauUsername: usernameSaisi,
          nouvelleBio: bioSaisie,
        );

        if (!mounted) return;

        // Affiche un petit message de confirmation high-tech
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: YrionTheme.cyanNeon,
            content: Text(
              "MATRICE D'IDENTITÉ SAUVEGARDÉE SUR LE SERVEUR", 
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );

        Navigator.pop(context); // Retour au profil
      } else {
        // Gestion des erreurs renvoyées par le serveur (ex: NOT_FOUND 404)
        _afficherErreur("ÉCHEC DE LA SYNCHRONISATION : CODE ${reponse.statusCode}");
      }
    } catch (e) {
      // Gestion des pannes de réseau
      _afficherErreur("ERREUR RESEAU : LE SERVEUR YRION EST INACCESSIBLE");
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
    return Scaffold(
      backgroundColor: YrionTheme.spaceDeep,
      body: SafeArea(
        child: Column(
          children: [
            /// 🛰️ EN-TÊTE NÉON OFFICIEL
            const CyberHeader(title: "ÉDITER L'IDENTITÉ", showBackButton: true),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),

                      /// 👤 ZONE DE RACCORDEMENT VERS LA PHOTO DE PROFIL
                      Center(
                        child: Column(
                          children: [
                            _buildAvatarApercu(),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _estEnCoursDeChargement ? null : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PhotoProfilPage()),
                                ).then((_) {
                                  setState(() {});
                                });
                              },
                              icon: const Icon(Icons.camera_alt_rounded, color: YrionTheme.cyanNeon, size: 18),
                              label: const Text(
                                "MODIFIER LA PHOTO",
                                style: TextStyle(color: YrionTheme.cyanNeon, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// 📝 CHAMP 1 : PSEUDONYME
                      _buildInputLabel("NOM D'AFFICHAGE"),
                      _buildCyberTextField(
                        controller: _pseudoController,
                        hint: "Ton nom ou pseudo...",
                        icon: Icons.person_outline_rounded,
                        enabled: !_estEnCoursDeChargement,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Le nom d'affichage ne peut pas être vide";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// 📝 CHAMP 2 : USERNAME (@)
                      _buildInputLabel("IDENTIFIANT UNIQUE (USERNAME)"),
                      _buildCyberTextField(
                        controller: _usernameController,
                        hint: "astronaute_du_974",
                        icon: Icons.alternate_email_rounded,
                        enabled: !_estEnCoursDeChargement,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "L'identifiant est obligatoire";
                          }
                          if (value.contains(' ')) {
                            return "Pas d'espaces dans l'identifiant";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// 📝 CHAMP 3 : BIO (Multi-lignes)
                      _buildInputLabel("BIOGRAPHIE DE LA CAPSULE"),
                      _buildCyberTextField(
                        controller: _bioController,
                        hint: "Raconte ton histoire dans l'espace Yrion...",
                        icon: Icons.notes_rounded,
                        enabled: !_estEnCoursDeChargement,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 40),

                      /// 💾 BOUTON DE SAUVEGARDE EN GRADIENT NÉON / INDICATEUR DE CHARGEMENT
                      GestureDetector(
                        onTap: _sauvegarderModifications,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _estEnCoursDeChargement 
                                ? [Colors.grey.shade800, Colors.grey.shade900]
                                : [YrionTheme.cyanNeon, YrionTheme.magentaNeon],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _estEnCoursDeChargement ? [] : [
                              BoxShadow(
                                color: YrionTheme.cyanNeon.withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Center(
                            child: _estEnCoursDeChargement
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: YrionTheme.cyanNeon,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "ENREGISTRER LES CONFIGURATIONS",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Petit label au-dessus des champs de saisie
  Widget _buildInputLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: YrionTheme.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  /// Input de texte personnalisé Cyberpunk
  Widget _buildCyberTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      enabled: enabled,
      style: TextStyle(color: enabled ? Colors.white : Colors.white30, fontSize: 14),
      cursorColor: YrionTheme.cyanNeon,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        prefixIcon: Icon(icon, color: YrionTheme.textLight, size: 20),
        filled: true,
        fillColor: YrionTheme.cardBackground.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: YrionTheme.borderNeon.withOpacity(0.6)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: YrionTheme.borderNeon.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: YrionTheme.cyanNeon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: YrionTheme.magentaNeon),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: YrionTheme.magentaNeon, width: 1.5),
        ),
        errorStyle: const TextStyle(color: YrionTheme.magentaNeon, fontSize: 11),
      ),
    );
  }

  /// Génère l'aperçu de la photo actuelle (ou initiale) avec son halo
  Widget _buildAvatarApercu() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [YrionTheme.cyanNeon, YrionTheme.magentaNeon]),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: YrionTheme.spaceDeep, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 45,
          backgroundColor: YrionTheme.cardBackground,
          backgroundImage: ProfilData.avatarFichierLocal != null 
              ? FileImage(ProfilData.avatarFichierLocal!) 
              : null,
          child: ProfilData.avatarFichierLocal == null
              ? Text(
                  ProfilData.obtenirInitiale(),
                  style: const TextStyle(color: YrionTheme.cyanNeon, fontSize: 32, fontWeight: FontWeight.w900),
                )
              : null,
        ),
      ),
    );
  }
}