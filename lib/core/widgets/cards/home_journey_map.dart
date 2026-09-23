import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../features/home/data/datasources/vietnam_map_datasource.dart';
import '../../../features/home/data/vietnam_map_paths.dart';
import '../../../features/home/data/province_model.dart';
import 'dart:ui' as ui;

class HomeJourneyMap extends StatefulWidget {
  final List<Province> provinces;
  final double maxHeight;

  const HomeJourneyMap({
    super.key,
    required this.provinces,
    this.maxHeight = 450.0,
  });

  @override
  State<HomeJourneyMap> createState() => _HomeJourneyMapState();
}

class _HomeJourneyMapState extends State<HomeJourneyMap> {
  int? _selectedPathIndex;
  ui.Image? _patternImage;

  // Cache raw paths được build với tỉ lệ chuẩn Size(1, 1)
  static final List<Path> _rawPaths =
      VietNamMapDatasource.buildPaths(const Size(1, 1));

  static final Rect _mapBounds = () {
    Rect? bounds;
    for (final path in _rawPaths) {
      final b = path.getBounds();
      bounds = bounds == null ? b : bounds.expandToInclude(b);
    }
    return bounds ?? Rect.zero;
  }();

  @override
  void initState() {
    super.initState();
    _loadPatternImage();
  }

  Future<ui.Image> loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    return decodeImageFromList(bytes);
  }

  Future<void> _loadPatternImage() async {
    final image = await loadUiImage('assets/images/vietnam_patern.png');
    if (mounted) {
      setState(() => _patternImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provinceMap = <int, Province>{
      for (final p in widget.provinces)
        if (p.pathIndex != null) p.pathIndex!: p,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Kích thước khả dụng
        final targetWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        const padding = 8.0;
        final availableWidth = targetWidth - padding * 2;
        final availableHeight = widget.maxHeight - padding * 2;

        // 2. Tỉ lệ dài : rộng = 1.37 : 1 (height / width = 1.37)
        const double aspectHtoW = 1.37;

        // Tính kích thước nội dung bản đồ theo tỉ lệ 1.37 : 1 và khống chế tối đa widget.maxHeight
        double contentWidth = availableWidth;
        double contentHeight = contentWidth * aspectHtoW;

        if (contentHeight > availableHeight) {
          contentHeight = availableHeight;
          contentWidth = contentHeight / aspectHtoW;
        }

        final targetHeight = contentHeight + padding * 2;

        // 3. Scale X và Y độc lập theo kích thước nội dung tỉ lệ 1.37 : 1
        final scaleX = contentWidth / _mapBounds.width;
        final scaleY = contentHeight / _mapBounds.height;

        // Căn giữa theo chiều ngang và cách đều padding
        final offsetX = (targetWidth - contentWidth) / 2 - _mapBounds.left * scaleX;
        final offsetY = padding - _mapBounds.top * scaleY;

        final matrix = Matrix4.identity()
          ..translate(offsetX, offsetY)
          ..scale(scaleX, scaleY);

        final scaledPaths =
            _rawPaths.map((p) => p.transform(matrix.storage)).toList();

        final visitedIndices = widget.provinces
            .where((p) => p.isVisited && p.pathIndex != null)
            .map((p) => p.pathIndex!)
            .toSet();
        final checkinIndices =  widget.provinces
            .where((p) => p.isCheckedIn && p.pathIndex != null)
            .map((p) => p.pathIndex!)
            .toSet();
        final hoangSaPos = Offset(1.665 * scaleX + offsetX, 1.66 * scaleY + offsetY);
        final truongSaPos = Offset(1.95 * scaleX + offsetX, 3.30 * scaleY + offsetY);
        final phuQuocPos = Offset(0.45 * scaleX + offsetX, 3.25 * scaleY + offsetY);
        return SizedBox(
          width: targetWidth,
          height: targetHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    int? clicked;
                    for (int i = 0; i < scaledPaths.length; i++) {
                      if (scaledPaths[i].contains(details.localPosition)) {
                        clicked = i;
                        break;
                      }
                    }
                    if (clicked != _selectedPathIndex) {
                      setState(() => _selectedPathIndex = clicked);
                    }
                    if (clicked != null) {
                      debugPrint(
                        'CLICK: $clicked — ${provinceMap[clicked]?.name ?? "unknown"}',
                      );
                    }
                  },
                  child: CustomPaint(
                    size: Size(targetWidth, targetHeight),
                    painter: VietNamMapPainter(
                      paths: scaledPaths,
                      selectedPathIndex: _selectedPathIndex,
                      visitedPathIndices: visitedIndices,
                      checkinPathIndices: checkinIndices,
                      paternImage: _patternImage,
                      posHoangSa: hoangSaPos,
                      posTruongSa: truongSaPos,
                      posPhuQuoc: phuQuocPos,
                      context: context,
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 12,
                right: 12,
                child: MapLegend(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            color: Color(0xFF43A047),
            hasPattern: true,
            label: 'Đã check-in',
          ),
          SizedBox(height: 6),
          _LegendItem(
            color: Color(0xFF43A047),
            label: 'Đã đi',
          ),
          SizedBox(height: 6),
          _LegendItem(
            color: Color(0xFFa2c79c),
            label: 'Chưa đi',
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool hasPattern;

  const _LegendItem({
    required this.color,
    required this.label,
    this.hasPattern = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: const Color(0xFF37474F).withValues(alpha: 0.4),
              width: 0.8,
            ),
            image: hasPattern
                ? const DecorationImage(
                    image: AssetImage('assets/images/vietnam_patern.png'),
                    fit: BoxFit.cover,
                    opacity: 0.75,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}