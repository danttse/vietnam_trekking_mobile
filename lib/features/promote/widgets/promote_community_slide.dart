import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/post_card.dart';
import 'package:vietnam_trekking_mobile/features/community/data/models/post_model.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_slide_scaffold.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PromoteCommunitySlide extends StatelessWidget {
  const PromoteCommunitySlide({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final theAnhPost = PostModel(
      postId: 'promote_post_the_anh',
      authorId: 'user_the_anh',
      authorName: 'Thế Anh',
      trekPlaceName: 'Đỉnh Lảo Thẩn',
      content: 'Bình minh trên đỉnh Lảo Thẩn thật tuyệt vời mọi người ơi! Biển mây bồng bềnh ngút ngàn.',
      images: const [],
      reactionCount: 45,
      commentCount: 12,
      isLiked: true,
      createdAt: now.subtract(const Duration(hours: 2)),
    );
    final minhTuPost = PostModel(
      postId: 'promote_post_minh_tu',
      authorId: 'user_minh_tu',
      authorName: 'Minh Tú',
      trekPlaceName: 'Hà Giang',
      content: 'Cung đường đèo Mã Pí Lèng hùng vĩ, trải nghiệm tuyệt vời cùng những người bạn đồng hành!',
      images: const [
        'https://statics.vinpearl.com/ma-pi-leng-pass-01_1685042952.jpg',
      ],
      reactionCount: 89,
      commentCount: 24,
      isLiked: false,
      createdAt: now.subtract(const Duration(days: 3)),
    );

    return PromoteSlideScaffold(
      title: l10n.promoteCommunityTitle,
      description: l10n.promoteCommunityDesc,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PostCard(post: theAnhPost),
              PostCard(post: minhTuPost),
            ],
          ),
        ),
      ),
    );
  }
}
