import 'package:flutter/material.dart';
import 'package:guitar_shared_tabs/grid_painter.dart';

class ChordGridSelector extends StatelessWidget {
  final List<int> frets;
  final int startingFret; 
  final int barreFret;
  final int barreStartString;
  final int barreEndString;
  final Function(int string, int fret) onSelect;

  const ChordGridSelector({
    super.key, 
    required this.frets, 
    required this.startingFret, 
    this.barreFret = 0,
    this.barreStartString = 0,
    this.barreEndString = 5,
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    // 🛠️ CORRECTION MATHÉMATIQUE ICI : On calcule la position relative du barré
    double relativeBarreFret = (barreFret - startingFret + 1).toDouble();

    return SizedBox(
      height: 250,
      width: 200,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(200, 250), 
            painter: GridPainter(startingFret: startingFret) 
          ),
          
          // 🛠️ L'aperçu du barré utilise maintenant la position relative !
          if (barreFret > 0 && relativeBarreFret > 0 && relativeBarreFret <= 5)
            Positioned(
              top: (250 / 5) * (relativeBarreFret - 0.5) - 10, 
              left: (200 / 6) * barreStartString + 16,
              right: 200 - ((200 / 6) * barreEndString) - 48,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A5F).withOpacity(0.5), 
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, 
              // 🛠️ CORRECTION MAGIQUE : On force le ratio pour avoir des cases de pile 50px de haut !
              childAspectRatio: 2 / 3, 
            ),
            itemCount: 30,
            itemBuilder: (context, i) {
              int string = i % 6;
              int localFret = (i ~/ 6) + 1; 
              int absoluteFret = localFret + startingFret - 1; 
              
              bool isSelected = frets[string] == absoluteFret;
              
              return GestureDetector(
                onTap: () => onSelect(string, absoluteFret),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: isSelected ? const Color(0xFFFF5A5F) : Colors.transparent
                  ),
                  child: Center(
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