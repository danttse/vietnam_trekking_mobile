import 'dart:async';

/// Signals a confirmed activity; XP still comes from the server's rank profile.
class GamificationEventBus {
  static final GamificationEventBus _instance = GamificationEventBus._();
  factory GamificationEventBus() => _instance;
  GamificationEventBus._();
  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;
  void activityCompleted() => _controller.add(null);
}
