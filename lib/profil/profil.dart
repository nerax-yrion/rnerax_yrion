import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'package:nerax_yrion/theme/cyber_header.dart';
import 'profil_data.dart';
import 'photo_profil.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Variables locales dynamiques alimentées par la session
  String _pseudo = "Chargement...";
  String _username = "...";
  String _email = "...";
  String _bio = "Pas de biographie renseignée.";
  String _nbPublications = "0";
  String _nbAbonnes = "0";
  String _nbTribus = "0";
  File? _avatarFichierLocal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _chargerProfilDynamique();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Charge dynamiquement les informations uniques de l'utilisateur connecté
  Future<void> _chargerProfilDynamique() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Extraction des chaînes poussées lors de l'inscription / connexion
      _pseudo = prefs.getString('user_username') ?? "Recrue Yrion";
      _username = prefs.getString('user_username')?.toLowerCase().replaceAll(' ', '') ?? "user";
      _email = prefs.getString('user_email') ?? "non_renseigne@yrion.com";
      
      // On synchronise également avec ton gestionnaire statique temporaire si nécessaire
      _bio = prefs.getString('user_bio') ?? ProfilData.bio;
      _nbPublications = prefs.getString('user_nb_publis') ?? ProfilData.nbPublications;
      _nbAbonnes = prefs.getString('user_nb_abonnes') ?? ProfilData.nbAbonnes;
      _nbTribus = prefs.getString('user_nb_tribus') ?? ProfilData.nbTribus;
      
      // Vérification de la présence d'un avatar configuré localement
      _avatarFichierLocal = ProfilData.avatarFichierLocal;
    });
  }

  /// Génère l'initiale de secours de manière sécurisée
  String _obtenirInitiale() {
    if (_pseudo.isEmpty) return "Y";
    return _pseudo.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YrionTheme.spaceDeep,
      body: SafeArea(
        child: Column(
          children: [
            /// 🛰️ EN-TÊTE NÉON
            const CyberHeader(title: "MON PASSEPORT", showBackButton: false),

            Expanded(
              child: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            /// 👤 AVATAR UNIQUE (Image ou Initiale Néon Réactive)
                            _buildCyberAvatar(),

                            const SizedBox(height: 16),

                            /// 🏷️ IDENTITY BLOCK DYNAMIQUE (Pseudo & Identifiant)
                            Text(
                              "$_pseudo @$_username",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),

                            /// 📧 EXPOSITION DU MAIL DIRECTE (Demande Utilisateur Réglée)
                            Text(
                              _email,
                              style: TextStyle(
                                color: YrionTheme.cyanNeon.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// 📝 BIO DYNAMIQUE
                            Text(
                              _bio,
                              style: const TextStyle(
                                color: YrionTheme.textLight,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            /// 📊 COMPTEURS DE STATS FLUIDES
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(_nbPublications, "PUBLIS"),
                                _buildStatElementDivider(),
                                _buildStatColumn(_nbAbonnes, "ABONNÉS"),
                                _buildStatElementDivider(),
                                _buildStatColumn(_nbTribus, "TRIBUS"),
                              ],
                            ),

                            const SizedBox(height: 24),

                            /// 🛠️ BOUTON INTERACTIF D'IMAGE
                            _buildEditProfileButton(context),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                    
                    /// 📑 ONGLETS RESTE ACCROCHÉS AU DÉFILEMENT
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorColor: YrionTheme.cyanNeon,
                          indicatorWeight: 3,
                          labelColor: YrionTheme.cyanNeon,
                          unselectedLabelColor: YrionTheme.textMuted,
                          tabs: const [
                            Tab(icon: Icon(Icons.grid_view_rounded, size: 22)),
                            Tab(icon: Icon(Icons.repeat_rounded, size: 22)),
                            Tab(icon: Icon(Icons.bookmark_border_rounded, size: 22)),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMediaGrid(),
                    _buildMediaGrid(),
                    _buildMediaGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gestion intelligente et contrainte de l'avatar de l'utilisateur
  Widget _buildCyberAvatar() {
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
          BoxShadow(color: YrionTheme.cyanNeon, blurRadius: 15, spreadRadius: 1)
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(color: YrionTheme.spaceDeep, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: YrionTheme.cardBackground,
          backgroundImage: _avatarFichierLocal != null 
              ? FileImage(_avatarFichierLocal!) 
              : null,
          child: _avatarFichierLocal == null
              ? Text(
                  _obtenirInitiale(),
                  style: const TextStyle(
                    color: YrionTheme.cyanNeon,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: YrionTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildStatElementDivider() {
    return Container(height: 20, width: 1, color: YrionTheme.borderNeon.withOpacity(0.5));
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PhotoProfilPage()),
        ).then((_) {
          // Relance la lecture en SharedPreferences & ProfilData au retour de l'écran d'ajustement
          _chargerProfilDynamique(); 
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: YrionTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: YrionTheme.borderNeon),
        ),
        child: const Center(
          child: Text(
            "AJUSTER MON IMAGE VISUELLE",
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: YrionTheme.cardBackground.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: YrionTheme.borderNeon.withOpacity(0.5)),
          ),
          child: Center(
            child: Icon(Icons.blur_on_rounded, color: YrionTheme.textMuted.withOpacity(0.4), size: 24),
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
    return Container(color: YrionTheme.spaceDeep, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}