import 'package:flutter/foundation.dart';

/// Debug helper for Explore screen issues.
class ExploreDebugHelper {
  /// Print detailed place info for debugging.
  static void logPlaceDetails(Map<String, dynamic> place, {String prefix = ''}) {
    if (!kDebugMode) return;
    
    debugPrint('$prefix📍 Place Debug Info:');
    debugPrint('$prefix  - ID: ${place['trekkingPlaceId']}');
    debugPrint('$prefix  - Name: ${place['name']}');
    debugPrint('$prefix  - Province: ${place['provinceId']}');
    debugPrint('$prefix  - Mien: ${place['mien'] ?? 'NOT SET ❌'}');
    debugPrint('$prefix  - Images: ${(place['images'] as List?)?.length ?? 0}');
    debugPrint('$prefix  - Rating: ${place['ratingAverage']}');
    debugPrint('$prefix  - Routes: ${place['routes'] != null ? (place['routes'] as List).length : 'N/A'}');
  }
  
  /// Log all places summary.
  static void logPlacesSummary(List<Map<String, dynamic>> places, {String title = 'Places'}) {
    if (!kDebugMode) return;
    
    debugPrint('');
    debugPrint('========== $title (${places.length} items) ==========');
    
    final withMien = places.where((p) => p['mien'] != null).length;
    final withoutMien = places.length - withMien;
    
    debugPrint('📊 Summary:');
    debugPrint('  - Total: ${places.length}');
    debugPrint('  - With mien: $withMien ✅');
    debugPrint('  - Without mien: $withoutMien ${withoutMien > 0 ? '❌' : ''}');
    
    if (withMien > 0) {
      final mienCounts = <String, int>{};
      for (final place in places) {
        final mien = place['mien']?.toString();
        if (mien != null) {
          mienCounts[mien] = (mienCounts[mien] ?? 0) + 1;
        }
      }
      
      debugPrint('  - By region:');
      mienCounts.forEach((mien, count) {
        final label = _mienToLabel(mien);
        debugPrint('    • $label: $count');
      });
    }
    
    if (places.isNotEmpty) {
      debugPrint('');
      debugPrint('Sample places:');
      for (var i = 0; i < places.length && i < 3; i++) {
        logPlaceDetails(places[i], prefix: '  ');
      }
    }
    
    debugPrint('========================================');
    debugPrint('');
  }
  
  static String _mienToLabel(String mien) {
    switch (mien) {
      case 'mien-bac': return 'Miền Bắc';
      case 'mien-trung': return 'Miền Trung';
      case 'mien-nam': return 'Miền Nam';
      default: return mien;
    }
  }
  
  /// Check if place has required data for display.
  static bool isPlaceValid(Map<String, dynamic> place) {
    final hasId = place['trekkingPlaceId'] != null;
    final hasName = place['name']?.toString().isNotEmpty ?? false;
    
    return hasId && hasName;
  }
  
  /// Filter places that are invalid for display.
  static List<Map<String, dynamic>> filterValidPlaces(List<Map<String, dynamic>> places) {
    final valid = places.where(isPlaceValid).toList();
    
    if (kDebugMode && valid.length < places.length) {
      debugPrint('⚠️ Filtered out ${places.length - valid.length} invalid places');
    }
    
    return valid;
  }
}
