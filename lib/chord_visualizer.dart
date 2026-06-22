import 'package:flutter/material.dart';

class ChordVisualizer extends StatelessWidget {
  final String name;
  final List<int> frets; 
  final int startingFret; // 🛠️ NOUVEAU : On reçoit la case de départ

  const ChordVisualizer({
    super.key, 
    required this.name, 
    required this.frets, 
    this.startingFret = 1
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🛠️ Un peu plus de marge horizontale pour laisser la place au texte "5fr"
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          CustomPaint(
            size: const Size(160, 200),
            painter: ChordPainter(frets, startingFret), // 🛠️ On l'envoie au peintre
          ),
        ],
      ),
    );
  }
}

class ChordPainter extends CustomPainter {
  final List<int> frets;
  final int startingFret;
  ChordPainter(this.frets, this.startingFret);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black..strokeWidth = 2;
    
    // Dessin du manche
    for (int i = 0; i < 6; i++) {
      double x = (size.width / 5) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Dessin des cases (frettes)
    for (int i = 0; i < 5; i++) {
      double y = (size.height / 4) * i;
      
      // 🛠️ Si on est à la case 1, on fait le sillet bien épais
      if (i == 0 && startingFret == 1) {
        paint.strokeWidth = 6.0;
      } else {
        paint.strokeWidth = 2.0;
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 🛠️ NOUVEAU : Dessiner l'indicateur de frette ("5fr")
    if (startingFret > 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: "${startingFret}fr",
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, const Offset(-35, -5)); // On le décale sur la gauche
    }

    // Dessin des doigts
    final dotPaint = Paint()..color = const Color(0xFFFF5A5F);
    for (int i = 0; i < frets.length; i++) {
      if (frets[i] > 0) {
        double x = (size.width / 5) * i;
        
        // 🛠️ LA CORRECTION MATHÉMATIQUE EST ICI
        // On ramène la vraie frette (ex: 5) sur la grille locale (de 1 à 4)
        double relativeFret = (frets[i] - startingFret + 1).toDouble();
        double y = (size.height / 4) * (relativeFret - 0.5);
        
        canvas.drawCircle(Offset(x, y), 8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}