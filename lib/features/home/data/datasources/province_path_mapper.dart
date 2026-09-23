class ProvincePathMapper {
  static const Map<String, int> _provinceIdToPathIndex = {
    'can_tho': 0,
    'an_giang': 1,
    'dong_thap': 2,
    'da_nang': 3,
    'thua_thien_hue': 4,
    'quang_tri': 5,
    'ha_tinh': 6,
    'nghe_an': 7,
    'thanh_hoa': 8,
    'son_la': 9,
    'dien_bien': 10,
    'tuyen_quang': 11,
    'thai_nguyen': 12,
    'cao_bang': 13,
    'quang_ninh': 14,
    'lai_chau': 15,
    'lao_cai': 16,
    'bac_ninh': 17,
    'phu_tho': 18,
    'hai_phong': 19,
    'hung_yen': 20,
    'ninh_binh': 21,
    'ha_noi': 22,
    'ca_mau': 23,
    'vinh_long': 24,
    'tay_ninh': 25,
    'dong_nai': 26,
    'lam_dong': 27,
    'dak_lak': 28,
    'khanh_hoa': 29,
    'gia_lai': 30,
    'quang_ngai': 31,
    'tp_ho_chi_minh': 32,
    'lang_son': 33,
  };

  static final Map<int, String> _pathIndexToProvinceId = {
    for (final entry in _provinceIdToPathIndex.entries) entry.value: entry.key,
  };

  /// Lấy chỉ số SVG path (0..33) từ mã tỉnh (snake_case)
  static int? getPathIndex(String provinceId) =>
      _provinceIdToPathIndex[provinceId];

  /// Lấy mã tỉnh (snake_case) từ chỉ số SVG path
  static String? getProvinceId(int pathIndex) =>
      _pathIndexToProvinceId[pathIndex];
}
