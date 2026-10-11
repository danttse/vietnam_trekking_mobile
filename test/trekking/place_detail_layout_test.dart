import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/repositories/journey_repository.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/review_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/views/widgets/place_review_section.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/trekking_map_preview.dart';
import 'package:vietnam_trekking_mobile/features/explore/views/place_detail_screen.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/services/offline_map_storage_service.dart';
import 'package:vietnam_trekking_mobile/core/database/database.dart';

class _Reviews extends JourneyRepository {
  @override
  Future<List<ReviewModel>> getReviews(
    String placeId, {
    int page = 1,
    int limit = 20,
  }) async => [];
  @override
  Future<Map<String, dynamic>> getReviewEligibility(String placeId) async => {
    'canCreate': false,
    'canEdit': false,
  };
}

class _EmptyMaps extends OfflineMapStorageService {
  @override
  Future<DownloadedMap?> findReadyMap(String routeId, String placeId) async =>
      null;
}

class _Catalog extends TrekkingCatalogService {
  final bool hasMap;
  _Catalog({this.hasMap = true}) : super(client: Dio());

  @override
  Future<Map<String, dynamic>> getPlace(String placeId) async => {
    'name': 'Núi Bà Đen',
    'images': ['https://example.com/ba-den.jpg'],
    'address': 'Tây Ninh',
    'difficulty': 'HARD',
    'elevationMeters': 986,
    'averageDurationMinutes': 30,
    'description': 'Núi Bà Đen là ngọn núi lửa đã tắt nằm phần lớn ở phường Bình Minh, tỉnh Tây Ninh, Việt Nam.',
    if (hasMap) 'imageMapUrl': 'https://example.com/ba-den-map.jpg',
  };

  @override
  Future<List<RouteModel>> getRoutes(
    String placeId, {
    Map<String, dynamic>? place,
  }) async => [
    RouteModel.fromJson({
      'trekkingRouteId': 'r1',
      'trekkingPlaceId': placeId,
      'name': 'Đường cột điện',
      'estimatedDurationMinutes': 30,
    }, place: place ?? {}),
  ];
}

void main() {
  for (final width in [320.0, 390.0, 600.0]) {
    testWidgets(
      'place hero spans $width pixels, map follows routes without overflow',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: PlaceDetailScreen(
              placeId: 'p1',
              reviewRepository: _Reviews(),
              service: _Catalog(),
              mapStorage: _EmptyMaps(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final hero = tester.getRect(find.byKey(const ValueKey('place-hero')));
        expect(hero.left, 0);
        expect(hero.top, 0);
        expect(hero.width, width);
        expect(find.text('0.0 km'), findsNothing);
        expect(find.text('Chưa có cự ly · 30 phút'), findsOneWidget);
        final map = tester.widget<TrekkingMapPreview>(
          find.byType(TrekkingMapPreview),
        );
        expect(map.placeId, 'p1');
        expect(map.route, isNull);
        expect(
          tester.getTopLeft(find.byType(PlaceReviewSection)).dy,
          greaterThan(tester.getBottomLeft(find.byType(TrekkingMapPreview)).dy),
        );
        expect(
          tester.getTopLeft(find.byType(TrekkingMapPreview)).dy,
          greaterThan(tester.getBottomLeft(find.text('Đường cột điện')).dy),
        );
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('missing map and large text remain usable in light mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.5)),
          child: child!,
        ),
        home: PlaceDetailScreen(
          placeId: 'p1',
          reviewRepository: _Reviews(),
          service: _Catalog(hasMap: false),
          mapStorage: _EmptyMaps(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(find.text('Chưa tải bản đồ offline của địa điểm.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
