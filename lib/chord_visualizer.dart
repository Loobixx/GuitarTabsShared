import 'package:flutter/material.dart';

class ChordVisualizer extends StatelessWidget {
  final String name;
  final List<int> frets; 
  final int startingFret;
  
  // 🛠️ NOUVEAU : Les 3 variables pour le barré
  final int barreFret;
  final int barreStartString;
  final int barreEndString;

  const ChordVisualizer({
    super.key, 
    required this.name, 
    required this.frets, 
    this.startingFret = 1,
    this.barreFret = 0,
    this.barreStartString = 5,
    this.barreEndString = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          CustomPaint(
            size: const Size(160, 200),
            // 🛠️ On envoie toutes les infos au peintre
            painter: ChordPainter(frets, startingFret, barreFret, barreStartString, barreEndString),
          ),
        ],
      ),
    );
  }
}

class ChordPainter extends CustomPainter {
  final List<int> frets;
  final int startingFret;
  final int barreFret;
  final int barreStartString;
  final int barreEndString;

  ChordPainter(this.frets, this.startingFret, this.barreFret, this.barreStartString, this.barreEndString);

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
      if (i == 0 && startingFret == 1) {
        paint.strokeWidth = 6.0;
      } else {
        paint.strokeWidth = 2.0;
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Indicateur de frette ("5fr")
    if (startingFret > 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: "${startingFret}fr",
          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, const Offset(-35, -5)); 
    }

    // Le pinceau pour les doigts et le barré
    final dotPaint = Paint()
      ..color = const Color(0xFFFF5A5F)
      ..style = PaintingStyle.fill;
      
    final barrePaint = Paint()
      ..color = const Color(0xFFFF5A5F)
      ..strokeWidth = 14.0 // Une belle épaisseur pour le doigt
      ..strokeCap = StrokeCap.round; // Arrondi sur les bords, c'est plus joli !

    // 🛠️ NOUVEAU : Dessin du Barré (en premier pour qu'il soit sous les points)
    if (barreFret > 0) {
      // On ramène la frette du barré sur la grille locale
      double relativeBarreFret = (barreFret - startingFret + 1).toDouble();
      
      // On vérifie que le barré est bien visible sur cette portion du manche
      if (relativeBarreFret > 0 && relativeBarreFret <= 5) {
        double y = (size.height / 4) * (relativeBarreFret - 0.5);
        
        // Inversion car sur ton dessin la corde 5 est à gauche et la corde 0 à droite
        // (Rappel: i = 0 c'est la corde de gauche sur ton écran)
        double xStart = (size.width / 5) * (5 - barreStartString); 
        double xEnd = (size.width / 5) * (5 - barreEndString);

        // Si tu as gardé la logique standard de gauche à droite (0 à 5), c'est plutôt ça :
        double xLeft = (size.width / 5) * barreStartString;
        double xRight = (size.width / 5) * barreEndString;
        
        // On trace la barre
        canvas.drawLine(Offset(xLeft, y), Offset(xRight, y), barrePaint);
      }
    }

    // Dessin des doigts classiques (par dessus le barré)
    for (int i = 0; i < frets.length; i++) {
      if (frets[i] > 0) {
        double relativeFret = (frets[i] - startingFret + 1).toDouble();
        double x = (size.width / 5) * i;
        double y = (size.height / 4) * (relativeFret - 0.5);
        canvas.drawCircle(Offset(x, y), 8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}