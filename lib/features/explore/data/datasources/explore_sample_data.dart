import '../models/explore_place_model.dart';
import '../models/popular_trail_model.dart';

class ExploreSampleData {
  static const List<PopularTrailModel> popularTrails = [
    PopularTrailModel(
      id: 'trail_1',
      name: 'Hà Giang Loop',
      location: 'Hà Giang',
      length: '120 km',
      duration: '4N3Đ',
      difficulty: 'Trung bình',
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
    ),
    PopularTrailModel(
      id: 'trail_2',
      name: 'Động Phong Nha',
      location: 'Quảng Bình',
      length: '14 km',
      duration: '1N',
      difficulty: 'Dễ',
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=600&q=80',
    ),
    PopularTrailModel(
      id: 'trail_3',
      name: 'VQG Bạch Mã',
      location: 'Thừa Thiên Huế',
      length: '18 km',
      duration: '2N1Đ',
      difficulty: 'Trung bình',
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=600&q=80',
    ),
    PopularTrailModel(
      id: 'trail_4',
      name: 'Tà Năng - Phan Dũng',
      location: 'Lâm Đồng',
      length: '35 km',
      duration: '3N2Đ',
      difficulty: 'Thử thách',
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=600&q=80',
    ),
  ];

  static const List<ExplorePlaceModel> featuredPlaces = [
    ExplorePlaceModel(
      id: 'place_fansipan',
      name: 'Sapa - Chinh phục đỉnh Fansipan',
      province: 'Lào Cai',
      elevation: '3.143 m',
      difficulty: 'Khó',
      rating: 4.9,
      reviewCount: 320,
      distance: '12.5 km',
      duration: '2 ngày 1 đêm',
      imageUrl:
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80',
      tag: 'Nóc nhà Đông Dương',
    ),
    ExplorePlaceModel(
      id: 'place_ta_xua',
      name: 'Tà Xùa - Thiên đường mây',
      province: 'Sơn La',
      elevation: '2.865 m',
      difficulty: 'Trung bình',
      rating: 4.8,
      reviewCount: 245,
      distance: '14 km',
      duration: '2 ngày 1 đêm',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      tag: 'Săn mây',
    ),
    ExplorePlaceModel(
      id: 'place_lao_than',
      name: 'Lảo Thẩn - Bình minh mây',
      province: 'Lào Cai',
      elevation: '2.860 m',
      difficulty: 'Dễ',
      rating: 4.8,
      reviewCount: 180,
      distance: '16 km',
      duration: '2 ngày 1 đêm',
      imageUrl:
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80',
      tag: 'Cắm trại',
    ),
    ExplorePlaceModel(
      id: 'place_pu_ta_leng',
      name: 'Pu Ta Leng - Nóc nhà Lai Châu',
      province: 'Lai Châu',
      elevation: '3.049 m',
      difficulty: 'Rất khó',
      rating: 4.9,
      reviewCount: 110,
      distance: '33 km',
      duration: '3 ngày 2 đêm',
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
      tag: 'Đỉnh 3.000m+',
    ),
  ];

  static const List<ExplorePlaceModel> recommendedPlaces = [
    ExplorePlaceModel(
      id: 'rec_ta_nang',
      name: 'Tà Năng - Phan Dũng',
      province: 'Lâm Đồng',
      elevation: '1.982 m',
      difficulty: 'Vừa',
      rating: 4.9,
      reviewCount: 300,
      distance: '28 km',
      duration: '3N2Đ',
      imageUrl:
          'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?auto=format&fit=crop&w=600&q=80',
      tag: 'Phổ biến',
    ),
    ExplorePlaceModel(
      id: 'rec_lao_than',
      name: 'Chinh phục đỉnh Lảo Thẩn',
      province: 'Lào Cai',
      elevation: '2.860 m',
      difficulty: 'Khó',
      rating: 4.8,
      reviewCount: 180,
      distance: '16 km',
      duration: '2N1Đ',
      imageUrl:
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=600&q=80',
    ),
    ExplorePlaceModel(
      id: 'rec_ta_chi_nhu',
      name: 'Tà Chì Nhù',
      province: 'Yên Bái',
      elevation: '2.979 m',
      difficulty: 'Khó',
      rating: 4.9,
      reviewCount: 205,
      distance: '18 km',
      duration: '2N1Đ',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
      tag: 'Đại ngàn hoa tím',
    ),
    ExplorePlaceModel(
      id: 'rec_ba_den',
      name: 'Núi Bà Đen',
      province: 'Tây Ninh',
      elevation: '986 m',
      difficulty: 'Dễ',
      rating: 4.8,
      reviewCount: 420,
      distance: '8.5 km',
      duration: '1N',
      imageUrl:
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=600&q=80',
      tag: 'Cuối tuần',
    ),
  ];
}
