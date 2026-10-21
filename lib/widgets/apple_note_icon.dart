import 'package:flutter/cupertino.dart';

class AppleNoteIcon extends StatelessWidget {
  final Color color;
  final double size;

  const AppleNoteIcon({
    super.key,
    this.color = CupertinoColors.white,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AppleNotePainter(color: color),
    );
  }
}

class _AppleNotePainter extends CustomPainter {
  final Color color;

  _AppleNotePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Document outline
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.08, w * 0.72, h * 0.84),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(rect, strokePaint);

    // 3 Note Lines
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Line 1
    canvas.drawLine(
      Offset(w * 0.28, h * 0.32),
      Offset(w * 0.70, h * 0.32),
      linePaint,
    );
    // Line 2
    canvas.drawLine(
      Offset(w * 0.28, h * 0.50),
      Offset(w * 0.70, h * 0.50),
      linePaint,
    );
    // Line 3
    canvas.drawLine(
      Offset(w * 0.28, h * 0.68),
      Offset(w * 0.52, h * 0.68),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AppleNotePainter oldDelegate) => oldDelegate.color != color;
}
