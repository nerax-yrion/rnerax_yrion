import 'package:flutter/material.dart';

/// 🎛️ **PANNEAU DE CONTRÔLE SÉLECTEUR DE CHRONO YO**
class SelecteurChronoEphemere extends StatefulWidget {
  final double valeurInitialeSecondes;
  final ValueChanged<int> onDureeSelectionnee;

  const SelecteurChronoEphemere({
    super.key,
    required this.valeurInitialeSecondes,
    required this.onDureeSelectionnee,
  });

  @override
  State<SelecteurChronoEphemere> createState() => _SelecteurChronoEphemereState();
}

class _SelecteurChronoEphemereState extends State<SelecteurChronoEphemere> {
  late double _valeurActuelle;

  String _obtenirTexteLisible(int secondes) {
    if (secondes < 60) return "$secondes secondes";
    if (secondes < 3600) return "${(secondes / 60).floor()} minute(s)";
    return "${(secondes / 3600).floor()} heure(s)";
  }

  @override
  void initState() {
    super.initState();
    _valeurActuelle = widget.valeurInitialeSecondes;
  }

  @override
  Widget build(BuildContext context) {
    const colorBleuNeon = Color(0xFF00D2FF);
    const colorRoseFluo = Color(0xFFFF007F);
    const colorViolet = Color(0xFFE000FF);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0E0B1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Text(
            "MESSAGERIE ÉPHÉMÈRE",
            style: TextStyle(color: colorBleuNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            _obtenirTexteLisible(_valeurActuelle.toInt()),
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            "Le message s'effacera des deux côtés à la fin du compte à rebours.",
            style: TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorRoseFluo,
              inactiveTrackColor: Colors.white10,
              trackHeight: 6.0,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              overlayColor: colorViolet.withOpacity(0.2),
            ),
            child: Slider(
              value: _valeurActuelle,
              min: 20,
              max: 86400,
              divisions: 200,
              onChanged: (val) {
                setState(() => _valeurActuelle = val);
                widget.onDureeSelectionnee(val.toInt());
              },
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [colorBleuNeon, colorViolet, colorRoseFluo]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Confirmer le Chrono YO",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// se fichier a pour but de demande a l'utilisateur d'ajuster sans chrono comme il le veulent [entre  20(seconde) à 24(heure)]