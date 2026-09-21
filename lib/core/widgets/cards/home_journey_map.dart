import 'package:flutter/material.dart';

import '../../../features/home/data/datasources/vietnam_map_datasource.dart';
import '../../../features/home/data/vietnam_map_paths.dart';
import '../../../features/home/data/province_model.dart';

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
  int? _hoveredPathIndex;

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
  Widget build(BuildContext context) {
    final provinceMap = <int, Province>{
      for (final p in widget.provinces) p.pathIndex: p,
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
            .where((p) => p.visited)
            .map((p) => p.pathIndex)
            .toSet();

        return SizedBox(
          width: targetWidth,
          height: targetHeight,
          child: MouseRegion(
            onHover: (event) {
              int? found;
              for (int i = 0; i < scaledPaths.length; i++) {
                if (scaledPaths[i].contains(event.localPosition)) {
                  found = i;
                  break;
                }
              }
              if (found != _hoveredPathIndex) {
                setState(() => _hoveredPathIndex = found);
                if (found != null) {
                  debugPrint(
                    'HOVER: $found — ${provinceMap[found]?.name ?? "unknown"} '
                    '(${event.localPosition.dx.toInt()}, ${event.localPosition.dy.toInt()})',
                  );
                }
              }
            },
            onExit: (_) => setState(() => _hoveredPathIndex = null),
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
                if (clicked != _hoveredPathIndex) {
                  setState(() => _hoveredPathIndex = clicked);
                }
                debugPrint(
                  'CLICK: $clicked — ${provinceMap[clicked]?.name ?? "unknown"}',
                );
              },
              child: CustomPaint(
                size: Size(targetWidth, targetHeight),
                painter: VietNamMapPainter(
                  paths: scaledPaths,
                  hoveredPathIndex: _hoveredPathIndex,
                  visitedPathIndices: visitedIndices,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}