import '../models/route_model.dart';

class RouteSampleData {
  static List<RouteModel> getSampleRoutes() {
    return const [
      RouteModel(
        routeId: 'route_fansipan_01',
        trekkingPlaceId: 'place_fansipan',
        name: 'Cung leo Trạm Tôn - Fansipan',
        description: 'Cung đường leo Fansipan phổ biến, an toàn và có cảnh quan đẹp nhất.',
        province: 'Lào Cai',
        difficulty: RouteDifficulty.hard,
        distanceMeters: 28000,
        estimatedDuration: Duration(days: 2),
        elevationGain: 2100,
        maxElevation: 3143,
        startPoint: GeoPoint(latitude: 22.3364, longitude: 103.7749),
        endPoint: GeoPoint(latitude: 22.3034, longitude: 103.7753),
        encodedPolyline: '',
        mapVersion: 1,
        imageUrl:
            'https://www.vietnambooking.com/wp-content/uploads/2018/12/doc-mien-dat-nuoc-chiem-nguong-canh-dep-viet-nam-19122018-3.jpg',
      ),
      RouteModel(
        routeId: 'route_hagiang_01',
        trekkingPlaceId: 'place_hagiang',
        name: 'Cung đường đèo Mã Pí Lèng',
        description: 'Tuyến đường đèo hùng vĩ bậc nhất miền Bắc uốn lượn bên dòng sông Nho Quế.',
        province: 'Hà Giang',
        difficulty: RouteDifficulty.hard,
        distanceMeters: 120000,
        estimatedDuration: Duration(days: 3),
        elevationGain: 1500,
        maxElevation: 2000,
        startPoint: GeoPoint(latitude: 22.8233, longitude: 104.9836),
        endPoint: GeoPoint(latitude: 23.2355, longitude: 105.3184),
        encodedPolyline: '',
        mapVersion: 1,
        imageUrl:
            'https://bizweb.dktcdn.net/100/453/654/files/sapa.jpg?v=1655971221589',
      ),
      RouteModel(
        routeId: 'route_taxua_01',
        trekkingPlaceId: 'place_taxua',
        name: 'Sống lưng khủng long - Tà Xùa',
        description: 'Cung đường săn mây huyền ảo với tầm nhìn biển mây bồng bềnh.',
        province: 'Sơn La',
        difficulty: RouteDifficulty.moderate,
        distanceMeters: 15000,
        estimatedDuration: Duration(days: 2),
        elevationGain: 900,
        maxElevation: 2865,
        startPoint: GeoPoint(latitude: 21.3283, longitude: 104.4754),
        endPoint: GeoPoint(latitude: 21.3392, longitude: 104.4921),
        encodedPolyline: '',
        mapVersion: 1,
        imageUrl:
            'https://ik.imagekit.io/tvlk/blog/2023/04/go-and-share-san-may-ta-xua-7.jpeg',
      ),
      RouteModel(
        routeId: 'route_bachmoc_01',
        trekkingPlaceId: 'place_bachmoc',
        name: 'Cung đường Ky Quan San - Bạch Mộc',
        description: 'Đỉnh núi cao thứ 4 Việt Nam với bình minh trên đồi Muối ngoạn mục.',
        province: 'Lào Cai',
        difficulty: RouteDifficulty.extreme,
        distanceMeters: 30000,
        estimatedDuration: Duration(days: 3),
        elevationGain: 2500,
        maxElevation: 3046,
        startPoint: GeoPoint(latitude: 22.5113, longitude: 103.5822),
        endPoint: GeoPoint(latitude: 22.5054, longitude: 103.5888),
        encodedPolyline: '',
        mapVersion: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=800&q=80',
      ),
      RouteModel(
        routeId: 'route_tanang_01',
        trekkingPlaceId: 'place_tanang',
        name: 'Cung đường rừng đồi cỏ Tà Năng Phan Dũng',
        description: 'Cung trekking chuyển tiếp giữa cao nguyên Lâm Đồng và miền duyên hải Bình Thuận.',
        province: 'Lâm Đồng',
        difficulty: RouteDifficulty.hard,
        distanceMeters: 55000,
        estimatedDuration: Duration(days: 3),
        elevationGain: 1100,
        maxElevation: 1700,
        startPoint: GeoPoint(latitude: 11.6667, longitude: 108.3833),
        endPoint: GeoPoint(latitude: 11.4500, longitude: 108.6167),
        encodedPolyline: '',
        mapVersion: 1,
        imageUrl:
            'https://images.unsplash.com/photo-1510312305653-8ed496efae75?auto=format&fit=crop&w=800&q=80',
      ),
    ];
  }

  static RouteModel? getRouteById(String routeId) {
    try {
      return getSampleRoutes().firstWhere((r) => r.routeId == routeId);
    } catch (_) {
      return null;
    }
  }
}
