import 'package:flutter/foundation.dart';

import '../data/models/province_model.dart';
import '../data/datasources/province_sample_data.dart';

class HomeViewModel extends ChangeNotifier {
  List<Province> provinces = ProvinceData.provinces;
 

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
        .where((province) => province.visited)
        .toList();
  }

  void setHoveredPath(int? pathIndex) {
    if (_hoveredPathIndex == pathIndex) {
      return;
    }

    _hoveredPathIndex = pathIndex;
    notifyListeners();
  }
}