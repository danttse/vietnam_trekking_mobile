import 'package:flutter/material.dart';
import '../data/datasources/route_sample_data.dart';
import '../data/models/route_model.dart';

class RouteDetailViewModel extends ChangeNotifier {
  RouteModel? _route;
  bool _isDownloading = false;
  bool _isDownloaded = false;

  RouteDetailViewModel({RouteModel? route}) {
    if (route != null) {
      _route = route;
    } else {
      final routes = RouteSampleData.getSampleRoutes();
      _route = routes.isNotEmpty ? routes.first : null;
    }
  }

  RouteModel? get route => _route;
  bool get isDownloading => _isDownloading;
  bool get isDownloaded => _isDownloaded;

  String get routeName => _route?.name ?? 'Cung Langbiang Huyền Thoại';
  String get routeLocation => _route?.province ?? 'Lạc Dương, Lâm Đồng, Việt Nam';

  String get difficultyText {
    if (_route == null) return 'Khó (Level 3)';
    switch (_route!.difficulty) {
      case RouteDifficulty.easy:
        return 'Dễ';
      case RouteDifficulty.moderate:
        return 'Trung bình';
      case RouteDifficulty.hard:
        return 'Khó';
      case RouteDifficulty.extreme:
        return 'Cực khó';
    }
  }

  String get totalDistanceText =>
      '${_route?.distanceKm.toStringAsFixed(1) ?? "16.8"} km';

  String get elevationGainText =>
      '+${_route?.elevationGain.toInt() ?? "1,100"} m';

  String get maxElevationText =>
      '${_route?.maxElevation.toInt() ?? "2,167"} m';

  String get estimatedDurationText {
    if (_route == null) return '2 - 3 ngày';
    final days = _route!.estimatedDuration.inDays;
    return days > 1 ? '$days - ${days + 1} ngày' : '$days ngày';
  }

  String get heroImageUrl =>
      _route?.imageUrl ??
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800';

  String get mapImageUrl =>
      'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800';

  Future<void> downloadOfflineMap() async {
    _isDownloading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isDownloading = false;
    _isDownloaded = true;
    notifyListeners();
  }

  void setDownloaded(bool value) {
    _isDownloaded = value;
    notifyListeners();
  }
}
