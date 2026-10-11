import 'package:dio/dio.dart';

import '../../services/gamification_event_bus.dart';

class GamificationInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final request = response.requestOptions;
    final path = Uri.parse(request.path).path;
    if (request.method == 'POST' &&
        (path == '/checkins' ||
            path == '/checkins/sync' ||
            RegExp(r'^/journeys/[^/]+/complete$').hasMatch(path)) &&
        response.data is Map &&
        response.data['success'] == true) {
      GamificationEventBus().activityCompleted();
    }
    handler.next(response);
  }
}
