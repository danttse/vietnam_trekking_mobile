import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../core/widgets/cards/image_load_card.dart';
import '../../../core/widgets/cards/profile_achievement_card.dart';
import '../../../core/widgets/cards/profile_stat_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../community/views/community_share.dart';
import '../../profile/data/models/profile_model.dart';
import '../../profile/views/badge_detail_screen.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../viewmodels/checkin_success_viewmodel.dart';
import 'rate_milestone_screen.dart';

class CheckinSuccessScreen extends StatefulWidget {
  final MilestoneModel? milestone;
  final JourneyModel? journey;
  final List<AchievementModel>? achievements;
  final bool journeyFinished;

  const CheckinSuccessScreen({
    super.key,
    this.milestone,
    this.journey,
    this.achievements,
    this.journeyFinished = false,
  });

  @override
  State<CheckinSuccessScreen> createState() => _CheckinSuccessScreenState();
}

class _CheckinSuccessScreenState extends State<CheckinSuccessScreen> {
  late final CheckinSuccessViewModel _viewModel;
  final List<String> _checkinImages = [];
  bool _pickingImages = false;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckinSuccessViewModel(
      milestone: widget.milestone,
      journey: widget.journey,
      achievements: widget.achievements,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickCheckinImages() async {
    if (_pickingImages) return;
    final slots = 2 - _checkinImages.length;
    if (slots <= 0) return;
    setState(() => _pickingImages = true);
    try {
      final photos = await ImagePicker().pickMultiImage(imageQuality: 80);
      if (!mounted || photos.isEmpty) return;
      final root = await getApplicationDocumentsDirectory();
      final directory = Directory(p.join(root.path, 'checkin_photos'));
      await directory.create(recursive: true);
      for (final photo in photos.take(slots)) {
        final target = p.join(
          directory.path,
          '${DateTime.now().microsecondsSinceEpoch}_${p.basename(photo.path)}',
        );
        await File(photo.path).copy(target);
        if (!mounted) return;
        setState(() => _checkinImages.add(target));
      }
      final jId = widget.journey?.journeyId;
      if (jId != null && jId.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final existing =
            prefs.getStringList('journey_checkin_images_$jId') ?? [];
        for (final img in _checkinImages) {
          if (!existing.contains(img)) existing.add(img);
        }
        await prefs.setStringList('journey_checkin_images_$jId', existing);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không chọn được ảnh. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingImages = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: InkWell(
                      onTap: () {
                        final items = _viewModel.getAchievements(l10n);
                        if (items.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BadgeDetailScreen(
                                badge: items.first,
                                allBadges: items,
                              ),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.terrain,
                            size: 54,
                            color: Color(0xFF6ECB8E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.checkinCongratulation,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.journeyFinished
                        ? 'Hoàn thành hành trình!'
                        : l10n.checkinSuccessTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.checkinSuccessMessage(_viewModel.destinationName),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_viewModel.achievementsEarned.isNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        l10n.achievementsEarnedTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ..._viewModel.getAchievements(l10n).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProfileAchievementCard(
                        title: item.title,
                        description: item.description,
                        icon: item.icon,
                        isUnlocked: item.isUnlocked,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BadgeDetailScreen(
                                badge: item,
                                allBadges: _viewModel.getAchievements(l10n),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileStatCard(
                          value: _viewModel.countAchieveText,
                          label: l10n.statNewBadge,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileStatCard(
                          value: _viewModel.maxElevationText,
                          label: l10n.statMaxElevation,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileStatCard(
                          value: _viewModel.conqueredProvincesText,
                          label: l10n.statConqueredProvinces,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Thêm ảnh check-in (tối đa 2 ảnh)',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 72,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _checkinImages.length >= 2
                              ? null
                              : _pickCheckinImages,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 24,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.addPhoto,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _checkinImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ImageLoadCard(
                                  imageUrl: File(_checkinImages[index]),
                                  onTapRemove: () => setState(
                                    () => _checkinImages.removeAt(index),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: BtnLoginPrimary(
                      text: widget.journeyFinished
                          ? 'Quay lại hành trình'
                          : l10n.continueJourneyButton,
                      onPressed: () {
                        Navigator.pop(context, _checkinImages);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.journeyFinished)
                    SizedBox(
                      width: double.infinity,
                      child: BtnOutlineStyle(
                        text: l10n.ratePlaceButton,
                        icon: Icon(
                          Icons.star_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RateMilestoneScreen(
                                milestone: widget.milestone,
                                journey: widget.journey,
                              ),
                            ),
                          );
                          if (context.mounted)
                            Navigator.pop(context, _checkinImages);
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: BtnOutlineStyle(
                      text: l10n.shareAchievementButton,
                      icon: const SizedBox.shrink(),
                      onPressed: () {
                        final journey = widget.journey;
                        final content = widget.journeyFinished
                            ? 'Mình đã hoàn thành hành trình ${journey?.name ?? _viewModel.destinationName}! '
                                  'Cao độ: ${_viewModel.maxElevationText}. #TrekViet'
                            : 'Mình đã check-in ${_viewModel.destinationName}! '
                                  'Cao độ: ${_viewModel.maxElevationText}. '
                                  '${journey?.name ?? ''} #TrekViet';
                        if (journey == null) {
                          openCommunityShare(context, content: content);
                        } else {
                          shareJourneyToCommunity(
                            context,
                            journey,
                            content: content,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
