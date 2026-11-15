import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/widgets/carousels/paged_carousel.dart';
import 'package:vietnam_trekking_mobile/core/widgets/carousels/place_image_gallery.dart';

Widget app({bool enabled = true, int count = 3, bool autoplay = true}) =>
    MaterialApp(
      home: Scaffold(
        body: TickerMode(
          enabled: enabled,
          child: PagedCarousel(
            itemCount: count,
            height: 210,
            autoAdvanceInterval: autoplay ? const Duration(seconds: 3) : null,
            itemBuilder: (_, index) => ColoredBox(
              color: Colors.green,
              child: Center(child: Text('Page $index')),
            ),
          ),
        ),
      ),
    );
double currentPage(WidgetTester tester) =>
    tester.widget<PageView>(find.byType(PageView)).controller!.page!;
Future<void> tick(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 450));
}

void main() {
  testWidgets(
    'autoplay pauses while another route covers it and resets for a shorter list',
    (tester) async {
      await tester.pumpWidget(app());
      await tick(tester);
      expect(currentPage(tester), 1);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Details')),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6));
      final hiddenPager = tester.widget<PageView>(
        find.byType(PageView, skipOffstage: false),
      );
      expect(hiddenPager.controller!.page, 1);
      navigator.pop();
      await tester.pumpAndSettle();
      await tester.pumpWidget(app(count: 1));
      await tester.pumpAndSettle();
      expect(currentPage(tester), 0);
      await tick(tester);
      expect(currentPage(tester), 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'autoplay advances every three seconds and loops to the first page',
    (tester) async {
      await tester.pumpWidget(app());
      expect(currentPage(tester), 0);
      await tick(tester);
      expect(currentPage(tester), 1);
      await tick(tester);
      expect(currentPage(tester), 2);
      await tick(tester);
      expect(currentPage(tester), 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('autoplay pauses on a hidden tab and while backgrounded', (
    tester,
  ) async {
    await tester.pumpWidget(app(enabled: false));
    await tick(tester);
    expect(currentPage(tester), 0);
    await tester.pumpWidget(app());
    await tick(tester);
    expect(currentPage(tester), 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tick(tester);
    expect(currentPage(tester), 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tick(tester);
    expect(currentPage(tester), 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'a drag pauses autoplay and restarts the interval after release',
    (tester) async {
      await tester.pumpWidget(app());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump(const Duration(seconds: 4));
      expect(currentPage(tester), lessThan(0.5));
      await gesture.moveBy(const Offset(-400, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      final afterSwipe = currentPage(tester);
      await tester.pump(const Duration(seconds: 2));
      expect(currentPage(tester), afterSwipe);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('gallery accepts empty photos and one photo without indicators', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(height: 200, child: PlaceImageGallery(images: [])),
      ),
    );
    expect(find.byIcon(Icons.terrain_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          height: 200,
          child: PlaceImageGallery(
            images: ['', ' ', 'https://example.com/photo.jpg'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PageView>(find.byType(PageView))
          .childrenDelegate
          .estimatedChildCount,
      1,
    );
    expect(tester.takeException(), isNull);
  });
}
