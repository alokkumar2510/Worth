import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global crash interceptors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    triggerGlobalRestart(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    triggerGlobalRestart(error, stack);
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    triggerGlobalRestart(details.exception, details.stack);
    return const SizedBox.shrink();
  };

  // Initialize Firebase (graceful offline fallback)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Worth] Firebase init failed (offline?): $e');
  }

  runApp(
    const AppRestartBoundary(
      child: ProviderScope(
        child: WorthApp(),
      ),
    ),
  );
}
