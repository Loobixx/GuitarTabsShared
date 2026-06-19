import 'package:flutter/material.dart';

class ChordVisualizer extends StatelessWidget {
  final String name;
  final List<int> frets; // Ex: [-1, 3, 2, 0, 1, 0]

  const ChordVisualizer({super.key, required this.name, required this.frets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          CustomPaint(
            size: const Size(160, 200),
            painter: ChordPainter(frets),
          ),
        ],
      ),
    );
  }
}

class ChordPainter extends CustomPainter {
  final List<int> frets;
  ChordPainter(this.frets);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black..strokeWidth = 2;
    
    // Dessin du manche (simplifié)
    for (int i = 0; i < 6; i++) {
      double x = (size.width / 5) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Dessin des cases (frettes)
    for (int i = 0; i < 5; i++) {
      double y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Dessin des doigts
    final dotPaint = Paint()..color = const Color(0xFFFF5A5F);
    for (int i = 0; i < frets.length; i++) {
      if (frets[i] > 0) {
        double x = (size.width / 5) * i;
        double y = (size.height / 4) * (frets[i] - 0.5);
        canvas.drawCircle(Offset(x, y), 8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}