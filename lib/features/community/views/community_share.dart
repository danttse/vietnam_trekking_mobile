import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../journey/data/models/journey_model.dart';
import '../data/datasources/community_attachment_datasource.dart';
import '../data/models/post_model.dart';
import 'create_new_post_screen.dart';

Future<void> shareJourneyToCommunity(
  BuildContext context,
  JourneyModel journey, {
  String? content,
}) async {
  final l10n = AppLocalizations.of(context);
  if (journey.pendingSync ||
      !RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(journey.journeyId)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.syncBeforeCommunityShare ??
              'Vui lòng đồng bộ hành trình trước khi chia sẻ lên cộng đồng.',
        ),
      ),
    );
    return;
  }
  await openCommunityShare(
    context,
    content:
        content ??
        l10n?.shareJourneyDefaultContent(journey.name) ??
        'Hành trình trekking ${journey.name} của mình!',
    journey: CommunityAttachment(
      id: journey.journeyId,
      name: journey.name,
      placeId: RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(journey.trekkingPlaceId)
          ? journey.trekkingPlaceId
          : null,
      placeName: journey.route.placeName,
    ),
  );
}

/// Sharing opens an editable draft. Only submitting the composer publishes it.
Future<void> openCommunityShare(
  BuildContext context, {
  required String content,
  String type = 'NORMAL',
  CommunityAttachment? journey,
}) async {
  final post = await Navigator.push<PostModel>(
    context,
    MaterialPageRoute(
      builder: (_) => CreateNewPostScreen(
        initialContent: content,
        initialType: type,
        initialJourney: journey,
      ),
    ),
  );
  if (!context.mounted || post == null) return;
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        l10n?.postPublishedSuccess ?? 'Đã đăng bài viết lên cộng đồng.',
      ),
    ),
  );
}
