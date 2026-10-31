import 'package:flutter/material.dart';

import '../data/datasources/community_attachment_datasource.dart';
import '../data/models/post_model.dart';
import '../../journey/data/models/journey_model.dart';
import 'create_new_post_creen.dart';

Future<void> shareJourneyToCommunity(
  BuildContext context,
  JourneyModel journey, {
  String? content,
}) async {
  if (journey.pendingSync ||
      !RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(journey.journeyId)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Vui lòng đồng bộ hành trình trước khi chia sẻ lên cộng đồng.',
        ),
      ),
    );
    return;
  }
  await openCommunityShare(
    context,
    content:
        content ?? 'Mình đã hoàn thành hành trình ${journey.name}! #TrekViet',
    journey: CommunityAttachment(
      id: journey.journeyId,
      name: journey.name,
      placeId: RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(journey.trekkingPlaceId)
          ? journey.trekkingPlaceId
          : null,
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
      builder: (_) => CreateNewPostCreen(
        initialContent: content,
        initialType: type,
        initialJourney: journey,
      ),
    ),
  );
  if (!context.mounted || post == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Đã đăng bài viết lên cộng đồng.')),
  );
}
