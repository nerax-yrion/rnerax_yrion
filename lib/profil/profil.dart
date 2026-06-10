import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

                            /// 👤 AVATAR UNIQUE (Image ou Initiale Néon)
                            _buildCyberAvatar(),

                            const SizedBox(height: 16),

                            /// 🏷️ PSEUDONYME & BIO DYNAMIQUE
                            Text(
                              "${ProfilData.pseudo} @${ProfilData.username}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ProfilData.bio,
                              style: const TextStyle(
                                color: YrionTheme.textLight,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            /// 📊 COMPTEURS DE STATS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(ProfilData.nbPublications, "PUBLIS"),
                                _buildStatElementDivider(),
                                _buildStatColumn(ProfilData.nbAbonnes, "ABONNÉS"),
                                _buildStatElementDivider(),
                                _buildStatColumn(ProfilData.nbTribus, "TRIBUS"),
                              ],
                            ),

                            const SizedBox(height: 24),

                            /// 📝 BOUTON POUR CONFIGURER SON IMAGE
                            _buildEditProfileButton(context),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                    
                    /// 📑 ONGLETS
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

  /// Gestion intelligente de l'avatar de l'utilisateur
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
          // SI l'utilisateur a chargé sa propre photo : on l'affiche
          backgroundImage: ProfilData.avatarFichierLocal != null 
              ? FileImage(ProfilData.avatarFichierLocal!) 
              : null,
          // SINON : on n'affiche rien en fond et on place sa lettre au centre
          child: ProfilData.avatarFichierLocal == null
              ? Text(
                  ProfilData.obtenirInitiale(),
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
          setState(() {}); // Actualise la page au retour pour afficher la vraie photo choisie
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