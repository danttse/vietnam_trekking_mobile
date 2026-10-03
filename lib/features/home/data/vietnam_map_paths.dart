import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../../app/app_fonts.dart';

class VietNamMapPainter extends CustomPainter {
  final List<Path> paths;

  final int? selectedPathIndex;

  final Set<int> visitedPathIndices;
  final Set<int> checkinPathIndices;

  // Pattern dùng để tô tỉnh đã check-in
  final ui.Image? paternImage;

  // Logo dùng cho đảo / quần đảo
  final ui.Image? logoImage;

  final Offset? posHoangSa;
  final Offset? posTruongSa;
  final Offset? posPhuQuoc;

  final BuildContext context;

  static const _colorNormal = Color(0xFFA2C79C);
  static const _colorVisited = Color(0xFF43A047);
  static const _colorSelected = Color(0xFFB9DBC0);
  static const _colorBorder = Color(0xFF37474F);
  static const _colorDeepMap = Color(0xFF6E8B69);

  const VietNamMapPainter({
    required this.paths,
    this.selectedPathIndex,
    this.visitedPathIndices = const {},
    this.checkinPathIndices = const {},
    this.paternImage,
    this.logoImage,
    required this.posHoangSa,
    required this.posTruongSa,
    required this.posPhuQuoc,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _colorBorder
      ..strokeWidth = 0.8;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        4.0,
      );

    // ============================================================
    // 1. SHADOW MAP
    // ============================================================

    canvas.save();

    canvas.translate(0, 10);

    for (final path in paths) {
      canvas.drawPath(
        path,
        shadowPaint,
      );
    }

    canvas.restore();

    // ============================================================
    // 2. MAP DEPTH
    // ============================================================

    final deepPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _colorDeepMap;

    canvas.save();

    canvas.translate(0, 5);

    for (final path in paths) {
      canvas.drawPath(
        path,
        deepPaint,
      );
    }

    canvas.restore();

    // ============================================================
    // 3. DRAW PROVINCES
    // ============================================================

    for (int i = 0; i < paths.length; i++) {
      final path = paths[i];

      final isSelected = i == selectedPathIndex;
      final isVisited = visitedPathIndices.contains(i);

      // Shadow cho tỉnh đang chọn
      if (isSelected) {
        canvas.drawShadow(
          path,
          Colors.black,
          10,
          true,
        );
      }

      // Màu tỉnh
      fillPaint.color = isSelected
          ? _colorSelected
          : isVisited
              ? _colorVisited
              : _colorNormal;

      canvas.drawPath(
        path,
        fillPaint,
      );

      canvas.drawPath(
        path,
        strokePaint,
      );

      // ========================================================
      // PATTERN CHECK-IN
      // ========================================================

      if (checkinPathIndices.contains(i) &&
          paternImage != null) {
        canvas.save();

        canvas.clipPath(path);

        final bounds = path.getBounds();

        final matrix = Matrix4.identity()
          ..translate(
            bounds.left,
            bounds.top,
          )
          ..scale(
            0.06,
            0.06,
          );

        final patternShader = ui.ImageShader(
          paternImage!,
          TileMode.repeated,
          TileMode.repeated,
          matrix.storage,
        );

        final patternPaint = Paint()
          ..shader = patternShader
          ..color = const Color(0xFFFFFFFF)
              .withValues(alpha: 0.75);

        canvas.drawRect(
          bounds,
          patternPaint,
        );

        canvas.restore();
      }
    }

    // ============================================================
    // 4. IMPORTANT ISLANDS
    // ============================================================

    final hoangSa = posHoangSa;

    if (hoangSa != null) {
      _paintImportantIsland(
        canvas,
        title: 'QĐ. Hoàng Sa',
        subTitle: 'Đà Nẵng',
        posCenter: hoangSa,
        showLogo: true,
      );
    }

    final truongSa = posTruongSa;

    if (truongSa != null) {
      _paintImportantIsland(
        canvas,
        title: 'QĐ. Trường Sa',
        subTitle: 'Khánh Hòa',
        posCenter: truongSa,
        showLogo: true,
      );
    }

    final phuQuoc = posPhuQuoc;

    if (phuQuoc != null) {
      _paintImportantIsland(
        canvas,
        title: 'Đ. Phú Quốc',
        subTitle: 'An Giang',
        posCenter: phuQuoc,
        showLogo: true,
      );
    }
  }

  // ==============================================================
  // IMPORTANT ISLAND
  // ==============================================================

  void _paintImportantIsland(
    Canvas canvas, {
    required String title,
    required String subTitle,
    required Offset posCenter,
    bool showLogo = false,
  }) {
    const logoSize = 8.0;
    const spacing = 2.0;

    // ------------------------------------------------------------
    // TITLE
    // ------------------------------------------------------------

    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface,
          fontSize: 6,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.primary,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    // ------------------------------------------------------------
    // SUBTITLE
    // ------------------------------------------------------------

    final subTitlePainter = TextPainter(
      text: TextSpan(
        text: '($subTitle)',
        style: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
          fontSize: 5,
          fontStyle: FontStyle.italic,
          fontFamily: AppFonts.primary,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    // ------------------------------------------------------------
    // TOTAL WIDTH
    // ------------------------------------------------------------

    final hasLogo = showLogo && logoImage != null;

    final titleRowWidth =
        titlePainter.width +
        (hasLogo ? logoSize + spacing : 0);

    final totalWidth = titleRowWidth > subTitlePainter.width
        ? titleRowWidth
        : subTitlePainter.width;

    final totalHeight =
        (titlePainter.height > logoSize
                ? titlePainter.height
                : logoSize) +
            subTitlePainter.height +
            1;

    final startX =
        posCenter.dx - totalWidth / 2;

    final startY =
        posCenter.dy - totalHeight / 2;

    // ------------------------------------------------------------
    // LOGO
    // ------------------------------------------------------------

    double titleX = startX;

    if (hasLogo) {
      final src = Rect.fromLTWH(
        0,
        0,
        logoImage!.width.toDouble(),
        logoImage!.height.toDouble(),
      );

      final dst = Rect.fromLTWH(
        startX,
        startY,
        logoSize,
        logoSize,
      );

      canvas.drawImageRect(
        logoImage!,
        src,
        dst,
        Paint()
          ..filterQuality =
              FilterQuality.high,
      );

      titleX += logoSize + spacing;
    }

    // ------------------------------------------------------------
    // TITLE DRAW
    // ------------------------------------------------------------

    final titleY = startY +
        ((logoSize - titlePainter.height)
                .clamp(0.0, double.infinity) /
            2);

    titlePainter.paint(
      canvas,
      Offset(
        titleX,
        titleY,
      ),
    );

    // ------------------------------------------------------------
    // SUBTITLE DRAW
    // ------------------------------------------------------------

    final rowHeight =
        titlePainter.height > logoSize
            ? titlePainter.height
            : logoSize;

    subTitlePainter.paint(
      canvas,
      Offset(
        posCenter.dx -
            subTitlePainter.width / 2,
        startY + rowHeight + 1,
      ),
    );
  }

  // ==============================================================
  // REPAINT
  // ==============================================================

  @override
  bool shouldRepaint(
    covariant VietNamMapPainter oldDelegate,
  ) {
    return oldDelegate.selectedPathIndex !=
            selectedPathIndex ||
        oldDelegate.paths != paths ||
        oldDelegate.visitedPathIndices !=
            visitedPathIndices ||
        oldDelegate.checkinPathIndices !=
            checkinPathIndices ||
        oldDelegate.paternImage !=
            paternImage ||
        oldDelegate.logoImage !=
            logoImage ||
        oldDelegate.posHoangSa !=
            posHoangSa ||
        oldDelegate.posTruongSa !=
            posTruongSa ||
        oldDelegate.posPhuQuoc !=
            posPhuQuoc;
  }

  // ==============================================================
  // HIT TEST
  // ==============================================================

  @override
  bool? hitTest(Offset position) {
    for (final path in paths) {
      if (path.contains(position)) {
        return true;
      }
    }

    return false;
  }
}