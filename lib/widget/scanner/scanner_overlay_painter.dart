import 'package:flutter/material.dart';

enum ScannerFrameStatus { idle, success, error }

class ScannerOverlayPainter extends CustomPainter {
  ScannerOverlayPainter({
    required this.cutOutRect,
    required this.status,
    required this.cornerProgress,
    this.borderRadius = 16,
    this.cornerLength = 28,
    this.cornerThickness = 4,
    this.overlayColor = const Color(0xCC000000),
  });

  final Rect cutOutRect;
  final ScannerFrameStatus status;
  final double cornerProgress;
  final double borderRadius;
  final double cornerLength;
  final double cornerThickness;
  final Color overlayColor;

  Color get _cornerColor {
    switch (status) {
      case ScannerFrameStatus.success:
        return const Color(0xFF22C55E);
      case ScannerFrameStatus.error:
        return const Color(0xFFEF4444);
      case ScannerFrameStatus.idle:
        return Colors.white;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius));

    final overlayPath = Path()
      ..addRect(fullRect)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, Paint()..color = overlayColor);

    final paint = Paint()
      ..color = _cornerColor
      ..strokeWidth = cornerThickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final len = cornerLength * cornerProgress.clamp(0.0, 1.0);
    final r = borderRadius;
    final rect = cutOutRect;

    // Top-left
    final tlPath = Path()
      ..moveTo(rect.left, rect.top + r + len)
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(
        Offset(rect.left + r, rect.top),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(rect.left + r + len, rect.top);
    canvas.drawPath(tlPath, paint);

    // Top-right
    final trPath = Path()
      ..moveTo(rect.right - r - len, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + r),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(rect.right, rect.top + r + len);
    canvas.drawPath(trPath, paint);

    // Bottom-right
    final brPath = Path()
      ..moveTo(rect.right, rect.bottom - r - len)
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(
        Offset(rect.right - r, rect.bottom),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(rect.right - r - len, rect.bottom);
    canvas.drawPath(brPath, paint);

    // Bottom-left
    final blPath = Path()
      ..moveTo(rect.left + r + len, rect.bottom)
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.bottom - r),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(rect.left, rect.bottom - r - len);
    canvas.drawPath(blPath, paint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter old) {
    return old.cutOutRect != cutOutRect ||
        old.status != status ||
        old.cornerProgress != cornerProgress ||
        old.overlayColor != overlayColor;
  }
}

class ScanningLinePainter extends CustomPainter {
  ScanningLinePainter({
    required this.cutOutRect,
    required this.progress,
    required this.color,
  });

  final Rect cutOutRect;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = cutOutRect.top + (cutOutRect.height * progress);
    final inset = 12.0;
    final left = cutOutRect.left + inset;
    final right = cutOutRect.right - inset;

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        color.withValues(alpha: 0),
        color.withValues(alpha: 0.95),
        color.withValues(alpha: 0),
      ],
      stops: const [0, 0.5, 1],
    );

    final rect = Rect.fromLTWH(left, y - 1.5, right - left, 3);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      paint,
    );

    // Soft glow halo
    final haloPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(left, y - 18, right - left, 36));
    canvas.drawRect(
      Rect.fromLTWH(left, y - 18, right - left, 36),
      haloPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanningLinePainter old) {
    return old.progress != progress ||
        old.cutOutRect != cutOutRect ||
        old.color != color;
  }
}
