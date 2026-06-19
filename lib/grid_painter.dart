import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54 // Couleur des lignes
      ..strokeWidth = 2.0;

    double stringSpacing = size.width / 6;
    double fretSpacing = size.height / 5;

    // 1. Dessiner les 6 cordes (lignes verticales)
    // On décale de stringSpacing/2 pour centrer les cordes dans les colonnes
    for (int i = 0; i < 6; i++) {
      double x = (i * stringSpacing) + (stringSpacing / 2);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 2. Dessiner les 5 cases (lignes horizontales)
    for (int i = 0; i <= 5; i++) {
      double y = i * fretSpacing;
      // On commence à stringSpacing/2 pour ne pas dépasser
      canvas.drawLine(Offset(stringSpacing / 2, y), Offset(size.width - (stringSpacing / 2), y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}