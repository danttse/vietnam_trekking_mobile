import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/card_home_stats.dart';
import 'package:vietnam_trekking_mobile/features/home/data/datasources/vietnam_map_datasource.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_slide_scaffold.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PromoteStatsSlide extends StatelessWidget {
  const PromoteStatsSlide({super.key});

  Widget _buildAchievementBadgeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PromoteSlideScaffold(
      title: l10n.promoteStatsTitle,
      description: l10n.promoteStatsDesc,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  const Expanded(
                    flex: 11,
                    child: _StaticVietnamMapCard(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CardHomeStats(
                          title: l10n.promoteStatsProvinces,
                          value: '10/34',
                          icon: Icons.map_outlined,
                          iconColor: colorScheme.primary,
                        ),
                        CardHomeStats(
                          title: l10n.promoteStatsDistance,
                          value: '192 km',
                          icon: Icons.directions_walk_rounded,
                          iconColor: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAchievementBadgeCard(
                    context: context,
                    icon: Icons.forest_rounded,
                    title: l10n.promoteStatsBadgeMountain,
                    subtitle: l10n.promoteStatsBadgeMountainSub,
                  ),
                  const SizedBox(width: 8),
                  _buildAchievementBadgeCard(
                    context: context,
                    icon: Icons.waves_rounded,
                    title: l10n.promoteStatsBadgeIsland,
                    subtitle: l10n.promoteStatsBadgeIslandSub,
                  ),
                  const SizedBox(width: 8),
                  _buildAchievementBadgeCard(
                    context: context,
                    icon: Icons.explore_rounded,
                    title: l10n.promoteStatsBadgeExplore,
                    subtitle: l10n.promoteStatsBadgeExploreSub,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticVietnamMapCard extends StatelessWidget {
  const _StaticVietnamMapCard();

  static final List<Path> _rawPaths = VietNamMapDatasource.buildPaths(
    const Size(1, 1),
  );

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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            if (w <= 0 || h <= 0) return const SizedBox.shrink();

            return CustomPaint(
              size: Size(w, h),
              painter: _StaticVietnamMapPainter(
                rawPaths: _rawPaths,
                mapBounds: _mapBounds,
                primaryColor: cs.primary,
                visitedColor: isDark
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF2E7D32),
                normalColor: isDark
                    ? const Color(0xFF334A3E)
                    : const Color(0xFFA5D6A7),
                borderColor: isDark
                    ? const Color(0xFF1B2A22)
                    : const Color(0xFF2E5939),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StaticVietnamMapPainter extends CustomPainter {
  final List<Path> rawPaths;
  final Rect mapBounds;
  final Color primaryColor;
  final Color visitedColor;
  final Color normalColor;
  final Color borderColor;

  // Sample visited indices representing ~10 explored provinces for illustration
  static const Set<int> _sampleVisitedIndices = {
    0, 3, 7, 12, 18, 24, 30, 35, 42, 50,
  };

  const _StaticVietnamMapPainter({
    required this.rawPaths,
    required this.mapBounds,
    required this.primaryColor,
    required this.visitedColor,
    required this.normalColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mapBounds.width <= 0 || mapBounds.height <= 0) return;

    const padding = 6.0;
    final availableWidth = size.width - padding * 2;
    final availableHeight = size.height - padding * 2;

    const double aspectHtoW = 1.37;
    double contentWidth = availableWidth;
    double contentHeight = contentWidth * aspectHtoW;

    if (contentHeight > availableHeight) {
      contentHeight = availableHeight;
      contentWidth = contentHeight / aspectHtoW;
    }

    final scaleX = contentWidth / mapBounds.width;
    final scaleY = contentHeight / mapBounds.height;

    final offsetX = (size.width - contentWidth) / 2 - mapBounds.left * scaleX;
    final offsetY = (size.height - contentHeight) / 2 - mapBounds.top * scaleY;

    final matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scaleX, scaleY);

    // 1. Soft Shadow
    final shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    canvas.save();
    canvas.translate(0, 3);
    for (final rawPath in rawPaths) {
      canvas.drawPath(rawPath.transform(matrix.storage), shadowPaint);
    }
    canvas.restore();

    // 2. Stroke and Fill
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = 0.5;

    final normalPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = normalColor.withValues(alpha: 0.6);

    final visitedPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = visitedColor;

    for (int i = 0; i < rawPaths.length; i++) {
      final p = rawPaths[i].transform(matrix.storage);
      final isVisited = _sampleVisitedIndices.contains(i);
      canvas.drawPath(p, isVisited ? visitedPaint : normalPaint);
      canvas.drawPath(p, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StaticVietnamMapPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.visitedColor != visitedColor ||
        oldDelegate.normalColor != normalColor ||
        oldDelegate.borderColor != borderColor;
  }
}
