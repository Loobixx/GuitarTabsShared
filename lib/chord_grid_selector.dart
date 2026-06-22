import 'package:flutter/material.dart';
import 'package:guitar_shared_tabs/grid_painter.dart';

class ChordGridSelector extends StatelessWidget {
  final List<int> frets;
  final int startingFret; // 🛠️ NOUVEAU : On reçoit le décalage
  final Function(int string, int fret) onSelect;

  const ChordGridSelector({
    super.key, 
    required this.frets, 
    required this.startingFret, 
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 200,
      child: Stack(
        children: [
          // Dessin du manche (lignes) avec le décalage
          CustomPaint(
            size: const Size(200, 250), 
            painter: GridPainter(startingFret: startingFret) // 🛠️ On l'envoie au dessinateur
          ),
          
          // Grille de clics invisibles
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Empêche le scroll parasite
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, 
              childAspectRatio: 0.7, 
            ),
            itemCount: 30,
            itemBuilder: (context, i) {
              int string = i % 6;
              
              // 🛠️ NOUVEAU : Calcul de la vraie frette
              int localFret = (i ~/ 6) + 1; // La ligne visuelle (1 à 5)
              int absoluteFret = localFret + startingFret - 1; // La vraie case sur la guitare
              
              bool isSelected = frets[string] == absoluteFret;
              
              return GestureDetector(
                onTap: () => onSelect(string, absoluteFret),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: isSelected ? const Color(0xFFFF5A5F) : Colors.transparent
                  ),
                  child: Center(
                    // Affiche le VRAI numéro de la frette si sélectionné
                    child: Text(
                      isSelected ? "$absoluteFret" : "",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}