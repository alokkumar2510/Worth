import 'dart:async';
import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../../../core/routes/router.dart';
import 'gamification_engine.dart';
import '../../presentation/widgets/achievement_overlay_manager.dart';

class AchievementQueueService {
  final Queue<GamificationEvent> _queue = Queue<GamificationEvent>();
  bool _isShowing = false;
  Timer? _breathingTimer;

  void enqueue(GamificationEvent event) {
    _queue.add(event);
    _processNext();
  }

  void _processNext() {
    if (_isShowing || _queue.isEmpty) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      // If the context is not yet available, wait and retry.
      Future.delayed(const Duration(milliseconds: 100), _processNext);
      return;
    }

    final event = _queue.removeFirst();
    _isShowing = true;

    // Trigger haptic feedback exactly once on entrance
    HapticFeedback.lightImpact();

    AchievementOverlayManager.show(
      context: context,
      event: event,
      onDismiss: () {
        _isShowing = false;
        // Enforce a "breathing window" delay before processing the next achievement
        _breathingTimer?.cancel();
        _breathingTimer = Timer(const Duration(milliseconds: 400), () {
          _processNext();
        });
      },
    );
  }

  void dispose() {
    _breathingTimer?.cancel();
    AchievementOverlayManager.dismiss();
  }
}
