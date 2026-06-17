import 'dart:async';
import '../../domain/services/achievement_queue_service.dart';
import '../../domain/services/gamification_engine.dart';

class MilestoneCelebrationController {
  final AchievementQueueService _queueService;
  final GamificationEngine _engine;
  StreamSubscription? _subscription;

  MilestoneCelebrationController(this._queueService, this._engine) {
    _subscription = _engine.events.listen((event) {
      _queueService.enqueue(event);
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
