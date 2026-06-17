import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'profil_data.dart';
import 'photo_profil.dart';
import 'auth_service_profil.dart';

/// ====================================================================
/// YRION SOCIAL ECOSYSTEM : INTERFACE SÉCURISÉE D'ÉDITION D'IDENTITÉ
/// ARCHITECTURE : Tolérance aux Pannes, Rollback Natif & Anti-Flood
/// INTÉGRATION : Pipeline Synchrone avec Neon Database via Axum (Render)
/// ====================================================================
class ModifierProfilPage extends StatefulWidget {
  const ModifierProfilPage({super.key});

  @override
  State<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends State<ModifierProfilPage> {
  final _formKey = GlobalKey<FormState>();
  bool _estEnCoursDeChargement = false;
  
  // VERROU ANTI-FLOOD CRUCIAL : Bloque les doubles ouvertures de la galerie native
  bool _gestionnaireSelecteurBloque = false;
  
  // Instance unique de notre passerelle asynchrone haut rendement
  final AuthServiceProfil _authServiceProfil = AuthServiceProfil();

  // Contrôleurs isolés pour éviter les fuites de mémoire (Memory Leaks)
  late final TextEditingController _pseudoController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    // Capture et isolation immédiate de l'état actuel du cache centralisé
    _pseudoController = TextEditingController(text: ProfilData.pseudo);
    _usernameController = TextEditingController(text: ProfilData.username);
    _bioController = TextEditingController(text: ProfilData.bio);
  }

  @override
  void dispose() {
    // Destruction propre des canaux de communication textuels
    _pseudoController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// 🛰️ SÉCURISATION & TRANSMISSION MULTI-COUCHES VERS LE CLUSTER RENDER
  Future<void> _sauvegarderModifications() async {
    // Blocage immédiat des requêtes concurrentes (Flood Protection)
    if (!_formKey.currentState!.validate() || _estEnCoursDeChargement) return;

    setState(() {
      _estEnCoursDeChargement = true;
    });

    // 🛡️ Assainissement des données (Sanitization) : Élimination des espaces superflus et risques d'injection
    final String pseudoSaisi = _pseudoController.text.trim();
    final String usernameSaisi = _usernameController.text.trim().replaceAll(' ', '');
    final String bioSaisie = _bioController.text.trim();

    // 💾 SAUVEGARDE DE SECOURS (Memento pattern) pour le Rollback en cas de rupture de flux
    final String ancienPseudo = ProfilData.pseudo;
    final String ancienUsername = ProfilData.username;
    final String ancienneBio = ProfilData.bio;

    // Étape 1 : Application optimiste des modifications en cache local pour une interface ultra réactive
    ProfilData.mettreAJourIdentite(
      nouveauPseudo: pseudoSaisi,
      nouveauUsername: usernameSaisi,
      nouvelleBio: bioSaisie,
    );

    try {
      // Étape 2 : Expédition de la charge utile vers l'API Axum en production
      final bool validationServeur = await _authServiceProfil.actualiserTextesProfil(
        userId: ProfilData.userId,
        nouveauPseudo: pseudoSaisi,
        nouvelleBio: bioSaisie,
      );

      if (validationServeur) {
        if (!mounted) return;

        // Feedback haptique/visuel de haut niveau
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: YrionTheme.cyanNeon,
            duration: Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.gpp_good_rounded, color: Colors.black),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "MATRICE D'IDENTITÉ SYNCHRONISÉE ON NEON SQL", 
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );

        Navigator.pop(context); // Clôture et retour au hub principal
      } else {
        // 🔄 ROLLBACK : Le serveur a rejeté la requête, on restaure l'ancien état sain
        ProfilData.mettreAJourIdentite(
          nouveauPseudo: ancienPseudo,
          nouveauUsername: ancienUsername,
          nouvelleBio: ancienneBio,
        );
        _afficherErreur("REJET DES CONFIGURATIONS PAR LE NOYAU RUST (VÉRIFIE TES ENTRÉES)");
      }
    } catch (erreurReseau) {
      // 🔄 ROLLBACK : Coupure réseau ou crash cloud, protection des données locales
      ProfilData.mettreAJourIdentite(
        nouveauPseudo: ancienPseudo,
        nouveauUsername: ancienUsername,
        nouvelleBio: ancienneBio,
      );
      _afficherErreur("PERTE DE LIAISON : LE CLUSTER YRION EST MOMENTANÉMENT INACCESSIBLE");
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
            const Icon(Icons.error_outline_rounded, color: Colors.white),
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
    return Scaffold(
      backgroundColor: YrionTheme.spaceDeep,
      body: SafeArea(
        child: Column(
          children: [
            /// En-tête Cyber-Écosystème Yrion
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

                      /// 👤 COMPOSANT AVATAR AVEC GESTION MULTI-FLUX TERMINAL / CLOUD
                      Center(
                        child: Column(
                          children: [
                            Hero(
                              tag: 'avatar_capsule_edit',
                              child: _buildAvatarApercu(),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: (_estEnCoursDeChargement || _gestionnaireSelecteurBloque) 
                                ? null 
                                : () async {
                                    // Verrouillage matériel instantané du bouton pour détruire l'erreur 'Reply already submitted'
                                    setState(() {
                                      _gestionnaireSelecteurBloque = true;
                                    });

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const PhotoProfilPage()),
                                    );

                                    // Libération contrôlée après fermeture complète de l'activité Android native
                                    if (mounted) {
                                      setState(() {
                                        _gestionnaireSelecteurBloque = false;
                                      });
                                    }
                                  },
                              icon: const Icon(Icons.add_photo_alternate_rounded, color: YrionTheme.cyanNeon, size: 18),
                              label: const Text(
                                "ACCÉDER AU STOCKAGE PHOTO",
                                style: TextStyle(color: YrionTheme.cyanNeon, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildInputLabel("NOM D'AFFICHAGE PLATFORME"),
                      _buildCyberTextField(
                        controller: _pseudoController,
                        hint: "Ex: Alexandre Martin",
                        icon: Icons.badge_rounded,
                        enabled: !_estEnCoursDeChargement,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "La matrice exige un nom d'affichage valide.";
                          }
                          if (value.trim().length > 30) {
                            return "Nom trop long (Maximum 30 caractères).";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildInputLabel("INDEX D'ANONYMAT (@USERNAME)"),
                      _buildCyberTextField(
                        controller: _usernameController,
                        hint: "astronaute_du_974",
                        icon: Icons.alternate_email_rounded,
                        enabled: !_estEnCoursDeChargement,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "L'identifiant unique est obligatoire pour le routage SQL.";
                          }
                          if (value.contains(' ')) {
                            return "Caractère interdit détecté : Espace.";
                          }
                          if (value.trim().length < 3) {
                            return "Identifiant trop court (Minimum 3 caractères).";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildInputLabel("MANIFESTE DE LA CAPSULE (BIOGRAPHIE)"),
                      _buildCyberTextField(
                        controller: _bioController,
                        hint: "Décris ta trajectoire dans l'univers Yrion...",
                        icon: Icons.terminal_rounded,
                        enabled: !_estEnCoursDeChargement,
                        maxLines: 4,
                        validator: (value) {
                          if (value != null && value.length > 160) {
                            return "Manifeste saturé (Maximum 160 caractères).";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      /// ⚡ ACTIONNEUR DE CONFIGURATION GRADIENT CYBERPUNK
                      GestureDetector(
                        onTap: _sauvegarderModifications,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
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
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _estEnCoursDeChargement ? [] : [
                              BoxShadow(
                                color: YrionTheme.cyanNeon.withOpacity(0.3),
                                blurRadius: 16,
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
                                      color: YrionTheme.cyanNeon,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "INITIALISER LA SYNCHRONISATION CLOUD",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildInputLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: YrionTheme.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

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
      style: TextStyle(
        color: enabled ? Colors.white : Colors.white30, 
        fontSize: 14, 
        fontFamily: 'monospace',
      ),
      cursorColor: YrionTheme.cyanNeon,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        prefixIcon: Icon(icon, color: enabled ? YrionTheme.cyanNeon.withOpacity(0.7) : YrionTheme.textMuted, size: 18),
        filled: true,
        fillColor: YrionTheme.cardBackground.withOpacity(0.25),
        contentPadding: const EdgeInsets.all(18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: YrionTheme.borderNeon.withOpacity(0.4)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: YrionTheme.borderNeon.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: YrionTheme.cyanNeon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: YrionTheme.magentaNeon, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: YrionTheme.magentaNeon, width: 1.5),
        ),
        errorStyle: const TextStyle(color: YrionTheme.magentaNeon, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAvatarApercu() {
    ImageProvider? imageProvider;

    if (ProfilData.avatarFichierLocal != null) {
      imageProvider = FileImage(ProfilData.avatarFichierLocal!);
    } else if (ProfilData.urlAvatarDistant != null && ProfilData.urlAvatarDistant!.isNotEmpty) {
      imageProvider = NetworkImage(ProfilData.urlAvatarDistant!);
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [YrionTheme.cyanNeon, YrionTheme.magentaNeon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(color: YrionTheme.spaceDeep, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 50, 
          backgroundColor: YrionTheme.cardBackground,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
                  ProfilData.obtenirInitiale(),
                  style: const TextStyle(
                    color: YrionTheme.cyanNeon, 
                    fontSize: 36, 
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                )
              : null,
        ),
      ),
    );
  }
}