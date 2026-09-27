import 'package:flutter/material.dart';
import '../data/datasources/explore_sample_data.dart';
import '../data/models/explore_place_model.dart';
import '../data/models/popular_trail_model.dart';

class ExploreViewModel extends ChangeNotifier {
  String _searchQuery = '';
  int _selectedRegion = 0;

  String get searchQuery => _searchQuery;
  int get selectedRegion => _selectedRegion;

  //SAMPLE
  static const List<String> _northProvinces = [
    'Lào Cai',
    'Lai Châu',
    'Yên Bái',
    'Sơn La',
    'Hà Giang',
    'Hà Nội',
    'Hòa Bình',
    'Điện Biên',
  ];

  static const List<String> _centralProvinces = [
    'Quảng Bình',
    'Thừa Thiên Huế',
    'Lâm Đồng',
    'Đà Nẵng',
    'Quảng Nam',
    'Phú Yên',
    'Khánh Hòa',
  ];

  static const List<String> _southProvinces = [
    'Tây Ninh',
    'Đồng Nai',
    'Bình Thuận',
    'TP.HCM',
    'Bà Rịa',
    'Long An',
  ];

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setRegion(int index) {
    if (_selectedRegion == index) return;
    _selectedRegion = index;
    notifyListeners();
  }

  bool _matchesRegion(String locationText) {
    switch (_selectedRegion) {
      case 0:
        return _northProvinces.any((p) => locationText.contains(p));
      case 1:
        return _centralProvinces.any((p) => locationText.contains(p));
      case 2:
        return _southProvinces.any((p) => locationText.contains(p));
      case 3:
        return true;
      default:
        return true;
    }
  }

  bool _matchesSearch(String name, String locationText) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return name.toLowerCase().contains(query) ||
        locationText.toLowerCase().contains(query);
  }

  List<ExplorePlaceModel> get featuredPlaces {
    return ExploreSampleData.featuredPlaces.where((place) {
      return _matchesRegion(place.province) &&
          _matchesSearch(place.name, place.province);
    }).toList();
  }

  List<PopularTrailModel> get popularTrails {
    return ExploreSampleData.popularTrails.where((trail) {
      return _matchesRegion(trail.location) &&
          _matchesSearch(trail.name, trail.location);
    }).toList();
  }

  List<ExplorePlaceModel> get recommendedPlaces {
    final filtered = ExploreSampleData.recommendedPlaces.where((place) {
      return _matchesRegion(place.province) &&
          _matchesSearch(place.name, place.province);
    }).toList();

    if (_selectedRegion == 3) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return filtered;
  }

}
