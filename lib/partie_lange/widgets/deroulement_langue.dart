// lib/widgets/deroulement_langue.dart
import 'package:flutter/material.dart';
import 'package:nerax_yrion/theme/yrion_theme.dart';

class DeroulementLangue extends StatelessWidget {
  final String titreContinent;
  final List<Map<String, String>> listeLangues;
  final String codeLangueSelectionnee;
  final bool estOuvertDoffice;
  final ValueChanged<String> auChoixLangue;

  const DeroulementLangue({
    super.key,
    required this.titreContinent,
    required this.listeLangues,
    required this.codeLangueSelectionnee,
    required this.estOuvertDoffice,
    required this.auChoixLangue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20) + const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: YrionTheme.cardBackground.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: Key(titreContinent + estOuvertDoffice.toString()),
          initiallyExpanded: estOuvertDoffice,
          iconColor: YrionTheme.cyanNeon,
          collapsedIconColor: Colors.white60,
          title: Text(
            titreContinent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listeLangues.length,
                itemBuilder: (context, index) {
                  final langue = listeLangues[index];
                  final bool estSelectionne = codeLangueSelectionnee == langue['code'];

                  return InkWell(
                    onTap: () => auChoixLangue(langue['code']!),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: estSelectionne 
                            ? YrionTheme.cyanNeon.withOpacity(0.1) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: estSelectionne ? YrionTheme.cyanNeon.withOpacity(0.7) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              langue['nom']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: estSelectionne ? FontWeight.bold : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (estSelectionne)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: YrionTheme.cyanNeon,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// se fichier va oermetre a mes utilisater de fair des recherche