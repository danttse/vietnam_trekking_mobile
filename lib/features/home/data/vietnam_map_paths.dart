import 'package:flutter/material.dart';

class VietNamMapPainter extends CustomPainter {
  final List<Path> paths;
  final int?       hoveredPathIndex;
  final Set<int>   visitedPathIndices;

  static const _colorNormal  = Color(0xFFa2c79c);
  static const _colorVisited = Color(0xFF43A047);
  static const _colorHover   = Color(0xFFb9dbc0);
  static const _colorBorder  = Color(0xFF37474F);

  const VietNamMapPainter({
    required this.paths,
    this.hoveredPathIndex,
    this.visitedPathIndices = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint   = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style       = PaintingStyle.stroke
      ..color       = _colorBorder
      ..strokeWidth = 0.8;

    for (int i = 0; i < paths.length; i++) {
      final path = paths[i];
      final isHovered = i == hoveredPathIndex;
      final isVisited = visitedPathIndices.contains(i);
      if (isHovered) {
        canvas.drawShadow(path, Colors.black, 10.0, true);
      }
      fillPaint.color = isHovered
          ? _colorHover
          : isVisited
              ? _colorVisited
              : _colorNormal;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(VietNamMapPainter old) =>
      old.hoveredPathIndex   != hoveredPathIndex   ||
      old.paths              != paths              ||
      old.visitedPathIndices != visitedPathIndices;

  @override
  bool? hitTest(Offset position) {
    for (final path in paths) {
      if (path.contains(position)) return true;
    }
    return false;
  }
}
