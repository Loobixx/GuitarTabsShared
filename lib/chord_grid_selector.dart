import 'package:flutter/material.dart';
import 'package:guitar_shared_tabs/grid_painter.dart';

class ChordGridSelector extends StatelessWidget {
  final List<int> frets;
  final Function(int string, int fret) onSelect;

  const ChordGridSelector({super.key, required this.frets, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 200,
      child: Stack(
        children: [
          // Dessin du manche (lignes)
          CustomPaint(size: const Size(200, 250), painter: GridPainter()),
          // Grille de clics invisibles
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, 
              childAspectRatio: 0.7, // Ajusté pour mieux centrer
            ),
            itemCount: 30,
            itemBuilder: (context, i) {
              int string = i % 6;
              int fret = (i ~/ 6) + 1;
              bool isSelected = frets[string] == fret;
              
              return GestureDetector(
                onTap: () => onSelect(string, fret),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: isSelected ? Colors.red : Colors.transparent
                  ),
                  child: Center(
                    // Affiche le numéro de la frette si sélectionné
                    child: Text(
                      isSelected ? "$fret" : "",
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