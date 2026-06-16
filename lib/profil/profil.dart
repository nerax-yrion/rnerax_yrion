import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'profil_data.dart';
import 'modifier_profil.dart'; 
import 'photo_profil.dart'; // 🧬 IMPORT ESSENTIEL : Élimine l'erreur d'appel de la page de recadrage

/// ============================================================================
/// YRION SOCIAL ECOSYSTEM : COMPOSANT PROFIL UTILISATEUR (MON PASSEPORT)
/// DESCRIPTION : Affichage ultra-haute performance et synchronisation asynchrone.
///               Gestion hybride SharedPreferences (Session) & ProfilData (Live Cache).
/// ARCHITECTURE UI : NestedScrollView, Slivers persistants & Réactivité temps réel.
/// ============================================================================
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  
  // États locaux dynamiques synchronisés
  String _pseudo = "Chargement...";
  String _username = "...";
  String _email = "...";
  String _bio = "Initialisation du manifeste...";
  
  // Correction des types : Alignement strict sur le modèle numérique de ProfilData (int)
  int _nbPublications = 0;
  int _nbAbonnes = 0;
  int _nbTribus = 0;
  
  File? _avatarFichierLocal;
  String? _urlAvatarDistant;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _chargerProfilDynamique();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  /// 🔄 Déclencheur automatique de rafraîchissement au retour au premier plan (App Lifecycle)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _chargerProfilDynamique();
    }
  }

  /// 🛰️ EXTRACTEUR ET SYNCHRONISATEUR DE FLUX DE DONNÉES
  Future<void> _chargerProfilDynamique() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Priorité 1 : Extraction du cache réactif en temps réel (ProfilData) pour refléter les modifications à la volée
      _pseudo = ProfilData.pseudo.isNotEmpty ? ProfilData.pseudo : (prefs.getString('user_username') ?? "Recrue Yrion");
      _username = ProfilData.username.isNotEmpty ? ProfilData.username : (prefs.getString('user_username')?.toLowerCase().replaceAll(' ', '') ?? "user");
      _email = ProfilData.email.isNotEmpty ? ProfilData.email : (prefs.getString('user_email') ?? "non_renseigne@yrion.com");
      _bio = ProfilData.bio.isNotEmpty ? ProfilData.bio : (prefs.getString('user_bio') ?? "Pas de biographie renseignée.");
      
      // Alignement direct et sécurisé sur tes entiers globaux
      _nbPublications = ProfilData.nbPublications;
      _nbAbonnes = ProfilData.nbAbonnes;
      _nbTribus = ProfilData.nbTribus;
      
      // Synchronisation des sources d'images locales et distantes
      _avatarFichierLocal = ProfilData.avatarFichierLocal;
      _urlAvatarDistant = ProfilData.urlAvatarDistant;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YrionTheme.spaceDeep,
      body: SafeArea(
        child: Column(
          children: [
            /// 🛰️ EN-TÊTE IMMERSIF CYBERPUNK
            const CyberHeader(title: "MON PASSEPORT", showBackButton: false),

            Expanded(
              child: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),

                            /// 👤 AVATAR HYBRIDE HAUTE DISPONIBILITÉ
                            Hero(
                              tag: 'avatar_capsule_edit',
                              child: _buildCyberAvatar(),
                            ),

                            const SizedBox(height: 18),

                            /// 🏷️ IDENTITY BLOCK (NOM & PROTOCOLE USERNAME)
                            Text(
                              _pseudo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "@$_username",
                              style: const TextStyle(
                                color: YrionTheme.textMuted,
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),

                            /// 📧 SIGNATURE RÉSEAU (EMAIL)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: YrionTheme.cyanNeon.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: YrionTheme.cyanNeon.withOpacity(0.15)),
                              ),
                              child: Text(
                                _email.toUpperCase(),
                                style: const TextStyle(
                                  color: YrionTheme.cyanNeon,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            /// 📝 BIO / MANIFESTE DE BORD
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _bio,
                                style: const TextStyle(
                                  color: YrionTheme.textLight,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 28),

                            /// 📊 MATRICE DES STATISTIQUES NUMÉRIQUES
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: YrionTheme.cardBackground.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: YrionTheme.borderNeon.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn(_nbPublications, "PUBLIS"),
                                  _buildStatElementDivider(),
                                  _buildStatColumn(_nbAbonnes, "ABONNÉS"),
                                  _buildStatElementDivider(),
                                  _buildStatColumn(_nbTribus, "TRIBUS"),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// 🛠️ ACTIONNEUR MULTI-PANELS DE MODIFICATION
                            _buildActionButtonsRow(context),

                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                    
                    /// 📑 SEGMENTATION DES ONGLETS (TAB BAR PERSISTANTE)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorColor: YrionTheme.cyanNeon,
                          indicatorWeight: 2.5,
                          labelColor: YrionTheme.cyanNeon,
                          unselectedLabelColor: YrionTheme.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          tabs: const [
                            Tab(icon: Icon(Icons.grid_view_rounded, size: 20)),
                            Tab(icon: Icon(Icons.bolt_rounded, size: 22)), 
                            Tab(icon: Icon(Icons.bookmark_border_rounded, size: 20)),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMediaGrid(Icons.grid_on_rounded),
                    _buildMediaGrid(Icons.bolt_rounded),
                    _buildMediaGrid(Icons.bookmark_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 👤 COMPOSANT TECHNIQUE DE L'AVATAR RÉACTIF
  Widget _buildCyberAvatar() {
    ImageProvider? imageAffichee;

    if (_avatarFichierLocal != null) {
      imageAffichee = FileImage(_avatarFichierLocal!);
    } else if (_urlAvatarDistant != null && _urlAvatarDistant!.isNotEmpty) {
      imageAffichee = NetworkImage(_urlAvatarDistant!);
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
        boxShadow: [
          BoxShadow(color: YrionTheme.cyanNeon, blurRadius: 16, spreadRadius: 0.5)
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(color: YrionTheme.spaceDeep, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 52,
          backgroundColor: YrionTheme.cardBackground,
          backgroundImage: imageAffichee,
          child: imageAffichee == null
              ? Text(
                  ProfilData.obtenirInitiale(), // 🎯 FIX : Utilise directement la méthode de ton ProfilData.dart
                  style: const TextStyle(
                    color: YrionTheme.cyanNeon,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(), 
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label, 
          style: const TextStyle(
            color: YrionTheme.textMuted, 
            fontSize: 9, 
            fontWeight: FontWeight.w800, 
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatElementDivider() {
    return Container(height: 24, width: 1, color: YrionTheme.borderNeon.withOpacity(0.2));
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ModifierProfilPage()),
              ).then((_) => _chargerProfilDynamique()); 
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [YrionTheme.cyanNeon, YrionTheme.magentaNeon]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: YrionTheme.cyanNeon.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: const Center(
                child: Text(
                  "ÉDITER LE PROFIL",
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PhotoProfilPage()),
            ).then((_) => _chargerProfilDynamique()); 
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: YrionTheme.cardBackground.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: YrionTheme.borderNeon.withOpacity(0.6)),
            ),
            child: const Icon(Icons.linked_camera_rounded, color: YrionTheme.cyanNeon, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(IconData icon) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: YrionTheme.cardBackground.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: YrionTheme.borderNeon.withOpacity(0.25)),
          ),
          child: Center(
            child: Icon(icon, color: YrionTheme.textMuted.withOpacity(0.25), size: 22),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: YrionTheme.spaceDeep, 
      child: Column(
        children: [
          tabBar,
          Divider(height: 1, color: YrionTheme.borderNeon.withOpacity(0.15)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}