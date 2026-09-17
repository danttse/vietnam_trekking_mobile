import '../models/province_model.dart';

class ProvinceData {
  static const List<Province> provinces = [
    Province(
      id: 1,
      name: 'Hà Giang',
      pathIndex: 12,
      visited: true,
      lastVisit: '12/10',
    ),

    Province(
      id: 2,
      name: 'Cao Bằng',
      pathIndex: 25,
      visited: false,
    ),

    Province(
      id: 3,
      name: 'Lào Cai',
      pathIndex: 7,
      visited: true,
      lastVisit: '05/10',
    ),
  ];
}