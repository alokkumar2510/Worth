import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'core/widgets/worth_background.dart';
import 'core/widgets/app_lock_guard.dart';
import 'database/seeder.dart';
import 'features/achievements/domain/services/gamification_engine.dart';
import 'features/achievements/presentation/widgets/achievement_dialog.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// A simple provider that reads the themeMode setting from the database.
/// Defaults to dark if the database hasn't loaded yet.
final themeModeProvider = StreamProvider<ThemeMode>((ref) async* {
  // Default to dark theme immediately while DB loads
  yield ThemeMode.dark;

  try {
    final db = ref.watch(realDatabaseProvider);
    await for (final settings in db.select(db.settings).watch()) {
      final map = {for (final s in settings) s.key: s.value};
      final mode = map['themeMode'] ?? 'dark';
      if (mode == 'light') {
        yield ThemeMode.light;
      } else if (mode == 'system') {
        yield ThemeMode.system;
      } else {
        yield ThemeMode.dark;
      }
    }
  } catch (_) {
    yield ThemeMode.dark;
  }
});

class WorthApp extends ConsumerStatefulWidget {
  const WorthApp({super.key});

  @override
  ConsumerState<WorthApp> createState() => _WorthAppState();
}

class _WorthAppState extends ConsumerState<WorthApp> {
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _gamificationSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToNotifications();
    _subscribeToGamification();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      final db = ref.read(realDatabaseProvider);
      await seedDatabaseIfEmpty(db);

      // Start background reminder scheduler
      ref.read(realReminderSchedulerProvider).start();

      // Start background Sync Engine
      ref.read(syncServiceProvider).start();
    } catch (e) {
      debugPrint('[Worth] Async services initialization failed: $e');
    }
  }

  void _subscribeToNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationSubscription = ref
          .read(realNotificationServiceProvider)
          .notificationStream
          .listen((notification) {
        scaffoldMessengerKey.currentState?.clearSnackBars();
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: notification.type == 'goal'
                    ? const Color(0xFF4CAF50)
                    : notification.type == 'liability'
                        ? const Color(0xFFF44336)
                        : notification.type == 'receivable'
                            ? const Color(0xFF2196F3)
                            : const Color(0xFFFF9800),
                width: 1,
              ),
            ),
            content: Row(
              children: [
                Icon(
                  notification.type == 'goal'
                      ? Icons.emoji_events
                      : notification.type == 'liability'
                          ? Icons.payment
                          : notification.type == 'receivable'
                              ? Icons.handshake
                              : Icons.monetization_on,
                  color: Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    });
  }

  void _subscribeToGamification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gamificationSubscription = ref
          .read(gamificationEngineProvider)
          .events
          .listen((event) {
        _showAchievementDialog(event);
      });
    });
  }

  void _showAchievementDialog(GamificationEvent event) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => AchievementDialog(event: event),
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _gamificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // Use the stream-based theme provider; default to dark while loading
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.dark;

    return MaterialApp.router(
      title: 'Worth',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AppLockGuard(
          child: WorthBackground(child: child ?? const SizedBox()),
        );
      },
    );
  }
}
