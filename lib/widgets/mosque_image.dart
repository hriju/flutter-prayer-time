import 'package:flutter/material.dart';

class MosqueImage extends StatelessWidget {
  final double height;
  final double width;

  const MosqueImage({
    super.key,
    this.height = 200,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.teal.shade200,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/mosque.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay for text readability if needed
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Optional: Add a title at the bottom
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Prayer Times',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalligraphicMosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.teal.shade100
      ..style = PaintingStyle.fill;

    // Create a calligraphic mosque silhouette
    final path = Path();
    
    // Base of the mosque
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.9, size.height * 0.8);
    
    // Right side wall
    path.lineTo(size.width * 0.9, size.height * 0.5);
    
    // Small right dome
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.4,
      size.width * 0.8, size.height * 0.5,
    );
    
    // Middle section
    path.lineTo(size.width * 0.75, size.height * 0.5);
    
    // Main dome
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.3,
      size.width * 0.5, size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.35, size.height * 0.3,
      size.width * 0.25, size.height * 0.5,
    );
    
    // Left section
    path.lineTo(size.width * 0.2, size.height * 0.5);
    
    // Small left dome
    path.quadraticBezierTo(
      size.width * 0.15, size.height * 0.4,
      size.width * 0.1, size.height * 0.5,
    );
    
    // Left wall
    path.lineTo(size.width * 0.1, size.height * 0.8);
    
    // Draw the main mosque silhouette
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
    
    // Add minaret on the right
    final rightMinaret = Path();
    rightMinaret.moveTo(size.width * 0.75, size.height * 0.8);
    rightMinaret.lineTo(size.width * 0.75, size.height * 0.3);
    rightMinaret.quadraticBezierTo(
      size.width * 0.75, size.height * 0.25,
      size.width * 0.78, size.height * 0.25,
    );
    rightMinaret.quadraticBezierTo(
      size.width * 0.81, size.height * 0.25,
      size.width * 0.81, size.height * 0.3,
    );
    rightMinaret.lineTo(size.width * 0.81, size.height * 0.8);
    
    canvas.drawPath(rightMinaret, fillPaint);
    canvas.drawPath(rightMinaret, paint);
    
    // Add minaret on the left
    final leftMinaret = Path();
    leftMinaret.moveTo(size.width * 0.25, size.height * 0.8);
    leftMinaret.lineTo(size.width * 0.25, size.height * 0.3);
    leftMinaret.quadraticBezierTo(
      size.width * 0.25, size.height * 0.25,
      size.width * 0.22, size.height * 0.25,
    );
    leftMinaret.quadraticBezierTo(
      size.width * 0.19, size.height * 0.25,
      size.width * 0.19, size.height * 0.3,
    );
    leftMinaret.lineTo(size.width * 0.19, size.height * 0.8);
    
    canvas.drawPath(leftMinaret, fillPaint);
    canvas.drawPath(leftMinaret, paint);
    
    // Add crescent moon on top of the main dome
    final crescentPath = Path();
    crescentPath.addArc(
      Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.2), radius: size.width * 0.05),
      0,
      3.14 * 2,
    );
    
    canvas.drawPath(crescentPath, fillPaint);
    canvas.drawPath(crescentPath, paint);
    
    // Add decorative arches for windows
    for (int i = 0; i < 3; i++) {
      final windowX = size.width * (0.25 + i * 0.25);
      final windowPath = Path();
      windowPath.moveTo(windowX - size.width * 0.08, size.height * 0.65);
      windowPath.lineTo(windowX - size.width * 0.08, size.height * 0.55);
      windowPath.quadraticBezierTo(
        windowX, size.height * 0.45,
        windowX + size.width * 0.08, size.height * 0.55,
      );
      windowPath.lineTo(windowX + size.width * 0.08, size.height * 0.65);
      
      canvas.drawPath(windowPath, paint);
    }
    
    // Add calligraphic details
    final detailPaint = Paint()
      ..color = Colors.teal.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    // Add dome details
    final domeDetailPath = Path();
    domeDetailPath.moveTo(size.width * 0.4, size.height * 0.35);
    domeDetailPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.28,
      size.width * 0.6, size.height * 0.35,
    );
    
    canvas.drawPath(domeDetailPath, detailPaint);
    
    // Add some Arabic-inspired calligraphic flourishes
    final flourishPath = Path();
    flourishPath.moveTo(size.width * 0.3, size.height * 0.9);
    flourishPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.85,
      size.width * 0.7, size.height * 0.9,
    );
    
    canvas.drawPath(flourishPath, detailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 