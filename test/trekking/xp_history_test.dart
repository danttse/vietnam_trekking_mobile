import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/models/xp_history_model.dart';
import 'package:vietnam_trekking_mobile/core/services/user_api_service.dart';
import 'package:vietnam_trekking_mobile/core/services/auth_event_bus.dart';
import 'package:vietnam_trekking_mobile/features/profile/view_models/xp_history_viewmodel.dart';

import 'frontend_api_integration_test.dart' show client;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'history uses API envelope, paginates and refreshes without duplicates',
    () async {
      final cursors = <dynamic>[];
      final api = UserApiService(
        authClient: client((request) {
          expect(request.path, '/gamification/me/xp-history');
          expect(request.queryParameters['limit'], 20);
          final cursor = request.queryParameters['cursor'];
          cursors.add(cursor);
          return {
            'success': true,
            'data': [
              {
                'xpTransactionId': 'first',
                'sourceType': 'PLACE_VISITED',
                'xpAmount': 50,
                'createdAt': '2026-10-11T00:00:00Z',
              },
              if (cursor != null)
                {
                  'xpTransactionId': 'second',
                  'sourceType': 'ADMIN_ADJUSTMENT',
                  'transactionType': 'REVERSAL',
                  'xpAmount': -10,
                },
            ],
            'pagination': {
              'nextCursor': cursor == null ? '2026-10-11T00:00:00Z' : null,
            },
          };
        }),
      );
      final vm = XpHistoryViewModel(api: api);
      await vm.load();
      expect(vm.items.single.amount, 50);
      expect(vm.items.single.createdAt!.isUtc, true);
      await vm.load();
      expect(vm.items.map((item) => item.id), ['first', 'second']);
      expect(vm.items.last.amount, -10);
      await vm.load();
      expect(cursors.length, 2);
      await vm.load(refresh: true);
      expect(vm.items.length, 1);
      expect(cursors.last, isNull);
      vm.dispose();
    },
  );

  test(
    'failed refresh keeps entries and can retry after the last page',
    () async {
      var fail = false;
      var requests = 0;
      final api = UserApiService(
        authClient: client((_) {
          requests++;
          if (fail) return {'_httpStatus': 500, 'message': 'Unavailable'};
          return {
            'success': true,
            'data': [
              {
                'xpTransactionId': 'first',
                'sourceType': 'PLACE_VISITED',
                'xpAmount': 50,
              },
            ],
            'pagination': {'nextCursor': null},
          };
        }),
      );
      final vm = XpHistoryViewModel(api: api);
      await vm.load();
      fail = true;
      await vm.load(refresh: true);
      expect(vm.items.length, 1);
      expect(vm.error, isNotNull);
      fail = false;
      await vm.load();
      expect(requests, 3);
      expect(vm.error, isNull);
      expect(vm.items.length, 1);
      vm.dispose();
    },
  );

  test('logout clears history and discards in-flight response', () async {
    final api = PendingHistoryApi();
    final vm = XpHistoryViewModel(api: api);
    final pending = vm.load();
    AuthEventBus().fire(AuthEvent.loggedOut);
    await Future<void>.delayed(Duration.zero);
    api.response.complete(
      const XpHistoryPage(
        items: [
          XpTransaction(
            id: 'old-user',
            sourceType: 'PLACE_VISITED',
            transactionType: 'EARN',
            amount: 50,
          ),
        ],
      ),
    );
    await pending;
    expect(vm.items, isEmpty);
    expect(vm.loaded, false);
    expect(vm.isLoading, false);
    vm.dispose();
  });
}

class PendingHistoryApi extends UserApiService {
  final response = Completer<XpHistoryPage>();
  @override
  Future<XpHistoryPage> getXpHistory({String? cursor, int limit = 20}) =>
      response.future;
}
