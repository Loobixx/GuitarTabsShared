import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  // 🛠️ NOUVEAU : On ajoute une variable pour connaître la case de départ
  final int startingFret; 

  GridPainter({this.startingFret = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2.0;

    double stringSpacing = size.width / 6;
    double fretSpacing = size.height / 5;

    // 1. Dessiner les 6 cordes (lignes verticales)
    for (int i = 0; i < 6; i++) {
      double x = (i * stringSpacing) + (stringSpacing / 2);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 2. Dessiner les 5 cases (lignes horizontales)
    for (int i = 0; i <= 5; i++) {
      double y = i * fretSpacing;
      
      // 🛠️ NOUVEAU : Le sillet (la ligne du haut) est plus épaisse si on est à la case 1
      if (i == 0 && startingFret == 1) {
        paint.strokeWidth = 6.0;
        paint.color = const Color(0xFF1E293B); // Une couleur plus sombre et affirmée
      } else {
        paint.strokeWidth = 2.0;
        paint.color = Colors.black54;
      }
      
      canvas.drawLine(Offset(stringSpacing / 2, y), Offset(size.width - (stringSpacing / 2), y), paint);
    }

    // 3. 🛠️ NOUVEAU : Dessiner l'indicateur de frette ("3fr") sur la gauche
    if (startingFret > 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: "${startingFret}fr",
          style: const TextStyle(
            color: Color(0xFF1E293B), 
            fontWeight: FontWeight.bold, 
            fontSize: 14
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      // On centre le texte à gauche de la toute première case dessinée
      textPainter.paint(canvas, Offset(0, fretSpacing / 2 - 8)); 
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    // 🛠️ On redessine le manche uniquement si on change de case de départ
    return oldDelegate.startingFret != startingFret; 
  }
}