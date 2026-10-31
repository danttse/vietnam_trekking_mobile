import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_event_bus.dart';
import '../../../../core/services/token_storage.dart';

class CommunityAttachment {
  final String id, name;
  final String? placeId;
  final String? placeName;
  const CommunityAttachment({
    required this.id,
    required this.name,
    this.placeId,
    this.placeName,
  });
}

class CommunityAttachmentPage {
  final List<CommunityAttachment> items;
  final bool hasMore;
  const CommunityAttachmentPage(this.items, this.hasMore);
}

/// Uses server-owned IDs; local/offline journey IDs must be synced first.
class CommunityAttachmentDataSource {
  final Dio dio;
  CommunityAttachmentDataSource([Dio? client])
    : dio =
          client ??
          DioClient.createTrekkingDio(
            tokenStorage: const SecureTokenStorage(),
            eventBus: AuthEventBus(),
          );

  Future<CommunityAttachmentPage> load({
    required bool journeys,
    int page = 1,
    String query = '',
  }) async {
    final response = await dio.get(
      journeys ? '/journeys' : '/places',
      queryParameters: {
        'page': page,
        'limit': 20,
        if (!journeys) 'summary': 'true',
        if (!journeys && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );
    final data = response.data['data'] as Map;
    final items = (data['items'] as List).map((raw) {
      final item = raw as Map;
      return CommunityAttachment(
        id: item[journeys ? 'journeyId' : 'trekkingPlaceId'] as String,
        name: item['name'] as String,
        placeId: journeys ? item['trekkingPlaceId'] as String? : null,
        placeName: journeys
            ? (item['trekkingPlaceName'] as String? ??
                item['placeName'] as String? ??
                ((item['route'] is Map)
                    ? (item['route'] as Map)['placeName'] as String?
                    : null) ??
                ((item['place'] is Map)
                    ? (item['place'] as Map)['name'] as String?
                    : null))
            : item['name'] as String?,
      );
    }).toList();
    final total = (data['total'] as num).toInt();
    return CommunityAttachmentPage(
      items,
      items.isNotEmpty && page * 20 < total,
    );
  }
}