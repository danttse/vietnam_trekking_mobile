import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../app/app_fonts.dart';

class VietNamMapPainter extends CustomPainter {
  final List<Path> paths;
  final int?       selectedPathIndex;
  final Set<int>   visitedPathIndices;
  final Set<int>   checkinPathIndices;
  final ui.Image? paternImage;
  final Offset? posHoangSa;
  final Offset? posTruongSa;
  final Offset? posPhuQuoc;
  final BuildContext context;

  static const _colorNormal   = Color(0xFFa2c79c);
  static const _colorVisited  = Color(0xFF43A047);
  static const _colorSelected = Color(0xFFb9dbc0);
  static const _colorBorder   = Color(0xFF37474F);
  static const _colorDeepMap  = Color(0xFF6E8B69);

  const VietNamMapPainter({
    required this.paths,
    this.selectedPathIndex,
    this.visitedPathIndices = const {},
    this.checkinPathIndices = const {},
    this.paternImage,
    required this.posHoangSa,
    required this.posTruongSa,
    required this.posPhuQuoc,
    required this.context
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint   = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style       = PaintingStyle.stroke
      ..color       = _colorBorder
      ..strokeWidth = 0.8;
    final shadowPaint=Paint()
      ..color=Colors.black.withValues(alpha: 0.4)
      ..maskFilter=MaskFilter.blur(BlurStyle.normal,4.0);
    canvas.save();
    canvas.translate(0, 10);
    for (int i=0;i<paths.length;i++) {
      canvas.drawPath(paths[i],shadowPaint);
    }
    canvas.restore();
    final deepPaint=Paint()
      ..style=PaintingStyle.fill
      ..color=_colorDeepMap;
    canvas.save();
    canvas.translate(0, 5);
    for (int i=0;i<paths.length;i++) {
      canvas.drawPath(paths[i],deepPaint);
    }
    canvas.restore();
    for (int i = 0; i < paths.length; i++) {
      final path = paths[i];
      final isSelected = i == selectedPathIndex;
      final isVisited = visitedPathIndices.contains(i);
      if (isSelected) {
        canvas.drawShadow(path, Colors.black, 10.0, true);
      }
      fillPaint.color = isSelected
          ? _colorSelected
          : isVisited
              ? _colorVisited
              : _colorNormal;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      if (checkinPathIndices.contains(i) && paternImage != null) {
        canvas.save();
        canvas.clipPath(path);
        final bounds=path.getBounds();
        final matrix = Matrix4.identity()
          ..translate(bounds.left, bounds.top)
          ..scale(0.06, 0.06);
        Shader patternShader=ImageShader(
          paternImage!,
          TileMode.repeated, TileMode.repeated, matrix.storage
        );
        final patternPaint=Paint()
        ..shader=patternShader
        ..color=Color(0xFFFFFFFF).withValues(alpha: 0.75);
        canvas.drawRect(bounds, patternPaint);
        canvas.restore();
      }
    }
    final hoangSa = posHoangSa;
    if (hoangSa != null) {
      _paintImportantIsland(canvas, title: "QĐ.Hoàng Sa", subTitle: "Đà Nẵng", posCenter: hoangSa);
    }
    final truongSa = posTruongSa;
    if (truongSa != null) {
      _paintImportantIsland(canvas, title: "QĐ.Trường Sa", subTitle: "Khánh Hòa", posCenter: truongSa);
    }
    final phuQuoc = posPhuQuoc;
    if (phuQuoc != null) {
      _paintImportantIsland(canvas, title: "Đ.Phú Quốc", subTitle: "An Giang", posCenter: phuQuoc);
    }
  }

  @override
  bool shouldRepaint(VietNamMapPainter old) =>
      old.selectedPathIndex  != selectedPathIndex  ||
      old.paths              != paths              ||
      old.visitedPathIndices != visitedPathIndices ||
      old.checkinPathIndices != checkinPathIndices;

  @override
  bool? hitTest(Offset position) {
    for (final path in paths) {
      if (path.contains(position)) return true;
    }
    return false;
  }

  void _paintImportantIsland(Canvas canvas,{required String title, required String subTitle, required Offset posCenter}) {
    final textPainter= TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title\n',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 6,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.primary,
            )
          ),
          TextSpan(
            text: '($subTitle)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 5,
              fontStyle: FontStyle.italic,
              fontFamily: AppFonts.primary,
            )
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
    )..layout();
    textPainter.paint(canvas,Offset(posCenter.dx-textPainter.width/2,posCenter.dy-textPainter.height/2));
  }
}
