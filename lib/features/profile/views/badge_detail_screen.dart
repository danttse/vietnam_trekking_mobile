import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../core/widgets/cards/profile_progress_bar.dart';
import '../data/models/badge_model.dart';
import '../data/models/profile_model.dart';
import '../view_models/badge_detail_viewmodel.dart';

class BadgeDetailScreen extends StatefulWidget {
  final dynamic badge;
  final List<dynamic>? allBadges;

  const BadgeDetailScreen({
    super.key,
    this.badge,
    this.allBadges,
  });

  @override
  State<BadgeDetailScreen> createState() => _BadgeDetailScreenState();
}

class _BadgeDetailScreenState extends State<BadgeDetailScreen> {
  late final BadgeDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final parsedBadge = _parseBadge(widget.badge);
    final parsedList = widget.allBadges?.map(_parseBadge).whereType<BadgeModel>().toList();

    _viewModel = BadgeDetailViewModel(
      badge: parsedBadge,
      allBadges: parsedList,
    );
  }

  BadgeModel? _parseBadge(dynamic b) {
    if (b == null) return null;
    if (b is BadgeModel) return b;
    if (b is AchievementModel) {
      final total = b.totalProgress > 0 ? b.totalProgress : 5;
      final current = b.totalProgress > 0 ? b.currentProgress : (b.isUnlocked ? total : 0);
      final unit = b.progressUnit.isNotEmpty ? b.progressUnit : 'Tỉnh thành';

      return BadgeModel(
        id: b.id,
        name: b.title,
        description: b.description,
        isUnlocked: b.isUnlocked,
        achievedDate: b.achievedDate ?? (b.isUnlocked ? '15/12/2025' : null),
        currentProgress: current,
        totalProgress: total,
        progressUnit: unit,
        icon: b.icon,
      );
    }
    return null;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final badge = _viewModel.currentBadge;
            final isUnlocked = badge.isUnlocked;

            return Column(
              children: [
                AppTopBarWithBack(
                  title: 'Chi tiết huy hiệu',
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUnlocked
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                              border: isUnlocked
                                  ? null
                                  : Border.all(
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                      width: 4,
                                    ),
                              boxShadow: isUnlocked
                                  ? [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(alpha: 0.5),
                                        blurRadius: 30,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              badge.icon,
                              size: 58,
                              color: isUnlocked
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          badge.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            badge.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (badge.achievedDate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Ngày đạt được: ${badge.achievedDate}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2ED573),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ProfileProvinceProgressBar(
                            title: 'TIẾN TRÌNH NHIỆM VỤ',
                            current: badge.currentProgress,
                            total: badge.totalProgress,
                            unit: badge.progressUnit,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'HUY HIỆU KHÁC CỦA BẠN',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Text(
                                    'Xem tất cả',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _viewModel.recentOtherBadges.map((item) {
                              final itemUnlocked = item.isUnlocked;
                              return InkWell(
                                onTap: () => _viewModel.selectBadge(item),
                                borderRadius: BorderRadius.circular(30),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: itemUnlocked
                                            ? colorScheme.primary.withValues(alpha: 0.15)
                                            : colorScheme.surfaceContainerHighest,
                                        border: Border.all(
                                          color: itemUnlocked
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        size: 28,
                                        color: itemUnlocked
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: itemUnlocked
                                            ? colorScheme.onSurface
                                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: BtnOutlineStyle(
                      text: 'Chia sẻ thành tích',
                      icon: const Icon(Icons.share_outlined, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
