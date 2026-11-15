import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/card_home_stats.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/home_journey_map.dart';
import 'package:vietnam_trekking_mobile/features/home/repository/province_visit_repository.dart';
import 'package:vietnam_trekking_mobile/features/home/view/home_screen.dart';
import 'package:vietnam_trekking_mobile/features/home/viewmodel/home_view_model.dart';
import 'package:vietnam_trekking_mobile/features/profile/view_models/profile_viewmodel.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class _UnusedRepository implements ProvinceVisitRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Profile extends ProfileViewModel {
  @override
  Future<void> ensureLoaded() async {}
}

class _Home extends HomeViewModel {
  _Home({required this.loading})
    : super(repository: _UnusedRepository(), autoLoad: false);

  final bool loading;

  @override
  bool get isLoadingProvinces => loading;
}

void main() {
  for (final config in [
    (size: const Size(393, 852), scale: 1.0, loading: false),
    (size: const Size(360, 640), scale: 1.0, loading: true),
    (size: const Size(320, 568), scale: 1.5, loading: false),
    (size: const Size(800, 400), scale: 1.0, loading: false),
  ]) {
    testWidgets('Home renders at $config without losing its content', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = config.size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final home = _Home(loading: config.loading);
      final profile = _Profile();
      addTearDown(home.dispose);
      addTearDown(profile.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<ProfileViewModel>.value(
          value: profile,
          child: MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('vi'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(config.scale)),
              child: child!,
            ),
            home: Scaffold(
              body: HomeScreen(viewModel: home),
              bottomNavigationBar: const SizedBox(height: 64),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(CardHomeStats), findsNWidgets(3));
      expect(find.byType(HomeJourneyMap), findsOneWidget);
      expect(
        tester.getSize(find.byType(HomeJourneyMap)).height,
        greaterThan(0),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(
        find.byIcon(Icons.camera_alt_outlined).hitTestable(),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
