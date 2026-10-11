import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/featured_place_card.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/popular_trail_card.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/recommended_place_card.dart';
import 'package:vietnam_trekking_mobile/features/explore/data/models/explore_place_model.dart';
import 'package:vietnam_trekking_mobile/features/explore/data/models/popular_trail_model.dart';

const _address = 'Linh Trung, Thu Duc, Tp HCM, Việt Nam';
const _place = ExplorePlaceModel(
  id: 'p1',
  name: 'ĐHQG — địa điểm có tên dài',
  province: _address,
  elevation: '',
  difficulty: 'MODERATE',
  rating: 4.5,
  reviewCount: 10,
  distance: '',
  duration: '120 phút',
  imageUrl: '',
);
const _trail = PopularTrailModel(
  id: 't1',
  name: 'Đường ktx khu A',
  location: _address,
  length: '0.0 km',
  duration: '120 phút',
  difficulty: 'MODERATE',
  rating: 4.5,
  imageUrl: '',
);

void main() {
  for (final scale in [1.0, 1.5]) {
    testWidgets('Explore cards fit long addresses at text scale $scale', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Center(
                child: SizedBox(
                  width: 320,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 210,
                          child: FeaturedPlaceCard(place: _place),
                        ),
                        SizedBox(
                          height: 120 + 11 * scale * 1.5 + 9 * scale * 1.5,
                          child: const PopularTrailCard(trail: _trail),
                        ),
                        RecommendedPlaceCard(
                          place: _place,
                          onTap: () => taps++,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(' • '), findsNothing);
      await tester.tap(find.byType(RecommendedPlaceCard));
      expect(taps, 1);
    });
  }
}
