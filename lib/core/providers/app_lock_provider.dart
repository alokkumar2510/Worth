import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_database.dart';

enum LockState {
  locked,
  unlocked,
}

class AppLockState {
  final LockState lockState;
  final DateTime? lastActiveTime;
  final bool isAuthenticating;

  AppLockState({
    required this.lockState,
    this.lastActiveTime,
    this.isAuthenticating = false,
  });

  bool get isLocked => lockState == LockState.locked;

  AppLockState copyWith({
    LockState? lockState,
    DateTime? lastActiveTime,
    bool? isAuthenticating,
  }) {
    return AppLockState(
      lockState: lockState ?? this.lockState,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }
}

class AppLockNotifier extends StateNotifier<AppLockState> {
  final Ref _ref;
  bool _hasAttemptedStartupLock = false;

  AppLockNotifier(this._ref)
      : super(AppLockState(lockState: LockState.unlocked)) {
    // Listen to mockDatabaseProvider to check if app lock is enabled on startup (cold start)
    _ref.listen<MockDatabaseState>(
      mockDatabaseProvider,
      (previous, next) {
        if (!_hasAttemptedStartupLock) {
          if (next.appLockEnabled) {
            state = state.copyWith(lockState: LockState.locked);
            _hasAttemptedStartupLock = true;
          } else if (previous != null) {
            // Database loaded and appLockEnabled is false
            _hasAttemptedStartupLock = true;
          }
        }
      },
      fireImmediately: true,
    );
  }

  void lockImmediately() {
    final dbState = _ref.read(mockDatabaseProvider);
    if (dbState.appLockEnabled) {
      state = state.copyWith(
        lockState: LockState.locked,
        lastActiveTime: null,
        isAuthenticating: false,
      );
    }
  }

  void setAuthenticating(bool authenticating) {
    state = state.copyWith(isAuthenticating: authenticating);
  }

  void unlock() {
    state = state.copyWith(
      lockState: LockState.unlocked,
      lastActiveTime: null,
      isAuthenticating: false,
    );
  }

  void recordBackgroundTime() {
    if (state.isAuthenticating) return;
    final dbState = _ref.read(mockDatabaseProvider);
    if (dbState.appLockEnabled) {
      state = state.copyWith(lastActiveTime: DateTime.now());
    }
  }

  void handleAppResumed() {
    if (state.isAuthenticating) return;
    final dbState = _ref.read(mockDatabaseProvider);
    if (!dbState.appLockEnabled) {
      state = state.copyWith(lockState: LockState.unlocked);
      return;
    }

    final lastTime = state.lastActiveTime;
    if (lastTime == null) {
      state = state.copyWith(lockState: LockState.locked);
      return;
    }

    final elapsedSeconds = DateTime.now().difference(lastTime).inSeconds;
    final timeout = dbState.appLockTimeout;
    
    if (elapsedSeconds >= timeout) {
      state = state.copyWith(lockState: LockState.locked);
    }
  }
}

final appLockProvider = StateNotifierProvider<AppLockNotifier, AppLockState>((ref) {
  return AppLockNotifier(ref);
});
