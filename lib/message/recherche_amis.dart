import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nerax_yrion/theme/yrion_theme.dart';
import 'chat_user_model.dart';
import 'carte_ami_recherche.dart'; // Importation de ton nouveau sous-composant
import '../profil/profil_data.dart';

class RechercheAmisPage extends StatefulWidget {
  const RechercheAmisPage({super.key});

  @override
  State<RechercheAmisPage> createState() => _RechercheAmisPageState();
}

class _RechercheAmisPageState extends State<RechercheAmisPage> {
  final TextEditingController _searchController = TextEditingController();
  final String _baseUrl = "https://ton-api-render.com/api";
  
  List<ChatUser> _serverResults = [];
  List<ChatUser> _filteredResults = [];
  List<String> _recentSearches = ["Camille", "Alex", "Yrion Dev"]; 
  
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {}); 

    if (query.trim().isEmpty) {
      setState(() {
        _filteredResults = [];
        _serverResults = [];
      });
      return;
    }

    _appliquerFiltrageLocal(query.trim());

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _rechercherUtilisateursDb(query.trim());
    });
  }

  void _appliquerFiltrageLocal(String query) {
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredResults = _serverResults.where((user) {
        return user.pseudo.toLowerCase().contains(lowercaseQuery) ||
               user.username.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  Future<void> _rechercherUtilisateursDb(String requete) async {
    if (requete.isEmpty) return;
    
    setState(() => _isLoading = _serverResults.isEmpty);

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/search?q=$requete&current_user=${ProfilData.userId}'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final nouveauxUtilisateurs = data.map((item) => ChatUser.fromJson(item)).toList();
        
        if (mounted && _searchController.text.trim() == requete) {
          setState(() {
            _serverResults = nouveauxUtilisateurs;
            _appliquerFiltrageLocal(requete);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Erreur recherche : $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sauvegarderDansHistorique(String pseudo) {
    if (!_recentSearches.contains(pseudo)) {
      setState(() {
        _recentSearches.insert(0, pseudo);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aSaisie = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF070512),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Recherche Intelligente",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [YrionTheme.cyanNeon.withOpacity(0.1), Colors.transparent]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Tape une lettre, un pseudo...",
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: YrionTheme.cyanNeon, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged("");
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.03),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: YrionTheme.cyanNeon, width: 1.2),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: YrionTheme.cyanNeon))
                      : !aSaisie
                          ? _buildHistoriqueSection()
                          : _filteredResults.isEmpty
                              ? _buildAucunResultat()
                              : _buildListeResultats(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueSection() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      children: [
        const Text("RECHERCHES RÉCENTES", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        ..._recentSearches.map((search) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded, color: Colors.white38, size: 20),
              title: Text(search, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              trailing: const Icon(Icons.north_west_rounded, color: Colors.white24, size: 16),
              onTap: () {
                _searchController.text = search;
                _searchController.selection = TextSelection.fromPosition(TextPosition(offset: search.length));
                _onSearchChanged(search);
              },
            )),
      ],
    );
  }

  Widget _buildAucunResultat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.02)),
            child: const Icon(Icons.radar_rounded, color: Colors.white24, size: 36),
          ),
          const SizedBox(height: 16),
          const Text("Le cercle se resserre...", style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Aucun membre ne correspond exactement.", style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildListeResultats() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final user = _filteredResults[index];
        // Utilisation directe du sous-composant isolé !
        return CarteAmiRecherche(
          user: user,
          queryText: _searchController.text,
          onTapCard: () => _sauvegarderDansHistorique(user.pseudo),
        );
      },
    );
  }
}