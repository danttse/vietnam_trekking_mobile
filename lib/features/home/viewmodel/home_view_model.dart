import 'package:flutter/foundation.dart';

import '../data/province_model.dart';
import '../data/recent_place_visited_model.dart';
import '../data/datasources/province_sample_data.dart';

class HomeViewModel extends ChangeNotifier {
  List<Province> provinces = List<Province>.from(ProvinceData.provinces);

  List<RecentPlace> recentPlaces = [
    const RecentPlace(name: 'Núi Bà Đen', lastVisited: '19/9'),
    const RecentPlace(name: 'Tháp Nghinh Phong', lastVisited: '17/11'),
  ];

  void addRecentPlace(RecentPlace place) {
    recentPlaces.insert(0, place);
    notifyListeners();
  }

  int? _hoveredPathIndex;

  int? get hoveredPathIndex => _hoveredPathIndex;

  Province? get hoveredProvince {
    final index = _hoveredPathIndex;

    if (index == null) {
      return null;
    }

    for (final province in provinces) {
      if (province.pathIndex == index) {
        return province;
      }
    }
    return null;
  }

  List<Province> get visitedProvinces {
    return provinces
        .where((province) => province.isVisited)
        .toList();
  }

  List<Province> get checkedInProvinces {
    return provinces
        .where((province) => province.isCheckedIn)
        .toList();
  }

  List<Province> get getListNorthernProvinces {
    return provinces
        .where((province) => province.region == Province.mienBac)
        .toList();
  }

  List<Province> get getListCentralnProvinces {
    return provinces
        .where((province) => province.region == Province.mienTrung)
        .toList();
  }

  List<Province> get getListSouththernProvinces {
    return provinces
        .where((province) => province.region == Province.mienNam)
        .toList();
  }

  void toggleProvinceVisited(String provinceId) {
    final index = provinces.indexWhere((p) => p.id == provinceId);
    if (index == -1) return;
    final current = provinces[index];
    final newVisited = !current.isVisited;
    provinces[index] = current.copyWith(isVisited: newVisited);
    notifyListeners();
  }

  void updateVisitedProvinces(Set<String> visitedIds) {
    for (int i = 0; i < provinces.length; i++) {
      final p = provinces[i];
      final shouldBeVisited = visitedIds.contains(p.id);
      if (p.isVisited != shouldBeVisited) {
        provinces[i] = p.copyWith(isVisited: shouldBeVisited);
      }
    }
    notifyListeners();
  }

  void setHoveredPath(int? pathIndex) {
    if (_hoveredPathIndex == pathIndex) {
      return;
    }
    _hoveredPathIndex = pathIndex;
    notifyListeners();
  }
}