// Android/iOS visual QA entry point. Fixture coordinates stay in this tool;
// the production app obtains routes, milestones and markers from its APIs.
import 'dart:io';
import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/core/database/models/downloaded_map.dart';
import 'package:vietnam_trekking_mobile/core/services/location_service.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/marker_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/milestone_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/views/journey_map_screen.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/data/offline_map_package_service.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/data/offline_package_installer.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/services/offline_map_storage_service.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final zip = File('${support.path}/journey-map-qa.zip');
  final target = Directory('${support.path}/qa_journey_map_v2');
  if (!await target.exists()) {
    await OfflinePackageInstaller().install(
      zip: zip,
      target: target,
      checksum: (await sha256.bind(zip.openRead()).first).toString(),
    );
  }
  final package = await OfflineMapPackageService().loadPackage(
    packageDirectory: target.path,
  );
  final manifest = package.manifest;
  final storage = _PreviewStorage(
    DownloadedMap(
      mapId: 'qa-journey-map',
      scope: 'PLACE',
      trekkingPlaceId: 'qa-ba-den',
      mapName: 'Bản đồ kiểm tra giao diện',
      localPath: '${package.extractDir}/${manifest.layers.first.file}',
      minLatitude: manifest.bounds[1],
      minLongitude: manifest.bounds[0],
      maxLatitude: manifest.bounds[3],
      maxLongitude: manifest.bounds[2],
    ),
  );
  final route = RouteModel.fromJson({
    'trekkingRouteId': 'qa-route',
    'trekkingPlaceId': 'qa-ba-den',
    'name': 'Cung đường kiểm tra giao diện',
    'path': {
      'type': 'LineString',
      'coordinates': [
        [107.368, 10.93],
        [107.374, 10.936],
        [107.378, 10.942],
        [107.382, 10.950],
      ],
    },
  });
  runApp(
    MaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: JourneyMapScreen(
        mapStorage: storage,
        journey: JourneyModel(
          journeyId: 'qa-trip',
          userId: '',
          name: route.name,
          route: route,
          status: JourneyStatus.active,
        ),
        routeId: route.routeId,
        milestones: const [
          MilestoneModel(
            id: 'qa-start',
            name: 'Điểm khởi hành',
            latitude: 10.93,
            longitude: 107.368,
            altitude: 200,
            isCheckedIn: true,
          ),
          MilestoneModel(
            id: 'qa-summit',
            name: 'Đỉnh núi',
            latitude: 10.950,
            longitude: 107.382,
            altitude: 986,
          ),
        ],
        markers: [
          MarkerModel(
            markerId: 'qa-viewpoint',
            localJourneyId: 'qa-trip',
            name: 'Điểm ngắm cảnh',
            type: 'VIEWPOINT',
            latitude: 10.942,
            longitude: 107.378,
            markedAt: DateTime.now(),
          ),
        ],
      ),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(LocationService.instance.initialize(requestPermission: true));
  });
}

// The real downloaded package is read by MapLibre. Only its catalog lookup is
// supplied by this fixture so no test rows enter the user's app database.
class _PreviewStorage extends OfflineMapStorageService {
  final DownloadedMap map;
  _PreviewStorage(this.map);
  @override
  Future<DownloadedMap?> findReadyMap(String routeId, String placeId) async =>
      map;
  @override
  Future<void> touchMap(String mapId) async {}
}
