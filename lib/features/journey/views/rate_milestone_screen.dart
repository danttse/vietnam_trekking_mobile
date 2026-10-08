import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/image_load_card.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../viewmodels/rate_milestone_viewmodel.dart';

class RateMilestoneScreen extends StatefulWidget {
  final MilestoneModel? milestone;
  final JourneyModel? journey;

  const RateMilestoneScreen({
    super.key,
    this.milestone,
    this.journey,
  });

  @override
  State<RateMilestoneScreen> createState() => _RateMilestoneScreenState();
}

class _RateMilestoneScreenState extends State<RateMilestoneScreen> {
  late final RateMilestoneViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RateMilestoneViewModel(
      milestone: widget.milestone,
      journey: widget.journey,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildRatingStars(int rating, ValueChanged<int> onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return GestureDetector(
          onTap: () => onRatingChanged(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              rating >= value
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
              size: 30,
            ),
          ),
        );
      }),
    );
  }
  Widget _buildPlaceholderImage(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.terrain_rounded, color: Colors.white38, size: 28),
    );
  }

  Widget _buildFormView(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        AppTopBarWithBack(
          title: l10n.ratePlaceTitle,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: _viewModel.milestoneImageUrl != null &&
                                  _viewModel.milestoneImageUrl!.isNotEmpty
                              ? Image.network(
                                  _viewModel.milestoneImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholderImage(colorScheme),
                                )
                              : _buildPlaceholderImage(colorScheme),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _viewModel.milestoneName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _viewModel.locationText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    l10n.rateSatisfactionLevel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildRatingStars(_viewModel.rating, _viewModel.setRating),
                const SizedBox(height: 24),
                EditTextAuthCustom(
                  label: l10n.rateShareExperience,
                  hintText: l10n.rateExperienceHint,
                  controller: _viewModel.descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.addImages,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_viewModel.selectedImages.length >=
                              RateMilestoneViewModel.maxImages) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chỉ được chọn tối đa 5 hình ảnh'),
                              ),
                            );
                          } else {
                            _viewModel.pickMultiImages();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: _viewModel.selectedImages.length >=
                                        RateMilestoneViewModel.maxImages
                                    ? 0.1
                                    : 0.25,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 24,
                                color: _viewModel.selectedImages.length >=
                                        RateMilestoneViewModel.maxImages
                                    ? colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.3)
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.addPhoto,
                                style: TextStyle(
                                  color: _viewModel.selectedImages.length >=
                                          RateMilestoneViewModel.maxImages
                                      ? colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.3)
                                      : colorScheme.onSurfaceVariant,
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
                          itemCount: _viewModel.selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ImageLoadCard(
                                imageUrl: _viewModel.selectedImages[index],
                                onTapRemove: () => _viewModel.removeImage(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_viewModel.selectedImages.length}/${RateMilestoneViewModel.maxImages}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.rateAnonymousLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.rateAnonymousDesc,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _viewModel.isAnonymous,
                      onChanged: _viewModel.setAnonymous,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: BtnLoginPrimary(
                    text: l10n.rateSubmitButton,
                    isLoading: _viewModel.isLoading,
                    onPressed: _viewModel.submit,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 96,
              height: 96,
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
                  Icons.check,
                  size: 46,
                  color: Color(0xFF2ED573),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            l10n.rateThankYouTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            l10n.rateThankYouMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 36),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  l10n.rateYourReviewTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 10),
                _buildRatingStars(_viewModel.rating, (_) {}),
                const SizedBox(height: 8),
                Text(
                  l10n.rateStarsSummary(_viewModel.rating, _viewModel.milestoneName),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            child: BtnOutlineStyle(
              text: l10n.rateViewOtherReviews,
              icon: const SizedBox.shrink(),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: BtnLoginPrimary(
              text: l10n.rateBackToHome,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
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
            if (_viewModel.isSubmitted) {
              return _buildSuccessView(context, colorScheme);
            }
            return _buildFormView(context, colorScheme);
          },
        ),
      ),
    );
  }
}
