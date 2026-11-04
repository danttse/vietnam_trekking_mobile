import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/core/database/database.dart'
    hide JourneyStatus;
import 'package:vietnam_trekking_mobile/core/widgets/cards/trekking_map_preview.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/services/offline_map_storage_service.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/features/route/view/route_detail_screen.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';

class _EmptyMaps extends OfflineMapStorageService {
  @override
  Future<DownloadedMap?> findReadyMap(String routeId, String placeId) async =>
      null;
}

void main() {
  testWidgets(
    'route detail shows its own photo, description, metrics, and parent offline map at narrow width',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final route = RouteModel.fromJson(
        {
          'trekkingRouteId': 'r',
          'trekkingPlaceId': 'p',
          'name': 'Cột điện',
          'description': 'Mô tả riêng của cung đường cột điện.',
          'difficulty': 'MODERATE',
          'distanceMeters': 3250,
          'estimatedDurationMinutes': 200,
          'elevationGain': 800,
          'maxElevation': 986,
          'imageUrl': 'https://cdn.example/route.jpg',
          'path': {
            'type': 'LineString',
            'coordinates': [
              [106.16, 11.38],
              [106.17, 11.39],
            ],
          },
        },
        place: {
          'name': 'Bà Đen',
          'images': ['https://cdn.example/place.jpg'],
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.3)),
            child: child!,
          ),
          home: RouteDetailScreen(
            route: route,
            mapStorage: _EmptyMaps(),
            pendingJourney: JourneyModel(
              journeyId: 'trip',
              name: 'Chuyến đi',
              route: route,
              status: JourneyStatus.planned,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final images = tester.widgetList<Image>(find.byType(Image));
      expect(images.map((i) => (i.image as NetworkImage).url), [
        'https://cdn.example/route.jpg',
      ]);
      expect(route.galleryImages, [
        'https://cdn.example/route.jpg',
        'https://cdn.example/place.jpg',
      ]);
      final pager = find.byType(PageView);
      await tester.drag(pager, const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(tester.widget<PageView>(pager).controller!.page, 1);
      expect(find.text('Mô tả riêng của cung đường cột điện.'), findsOneWidget);
      expect(find.text('Độ khó: Trung bình'), findsOneWidget);
      expect(find.text('Địa điểm: Bà Đen'), findsOneWidget);
      expect(find.text('3 giờ 20 phút'), findsOneWidget);
      expect(find.text('986 m'), findsOneWidget);
      final map = tester.widget<TrekkingMapPreview>(
        find.byType(TrekkingMapPreview),
      );
      expect(map.placeId, 'p');
      expect(map.route?.routeId, 'r');
      expect(map.route?.path.length, 2);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Bắt đầu hành trình'));
      await tester.pumpAndSettle();
      expect(find.text('Về trang hành trình'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
