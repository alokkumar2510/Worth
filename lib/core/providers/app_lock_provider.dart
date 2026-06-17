import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_database.dart';

enum LockState {
  locked,
  unlocking,
  unlocked,
}

class AppLockState {
  final LockState lockState;
  final DateTime? lastActiveTime;

  AppLockState({
    required this.lockState,
    this.lastActiveTime,
  });

  bool get isLocked => lockState == LockState.locked;

  AppLockState copyWith({
    LockState? lockState,
    DateTime? lastActiveTime,
  }) {
    return AppLockState(
      lockState: lockState ?? this.lockState,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
    );
  }
}

class AppLockNotifier extends StateNotifier<AppLockState> {
  final Ref _ref;

  AppLockNotifier(this._ref)
      : super(AppLockState(lockState: LockState.unlocked));

  void lockImmediately() {
    final dbState = _ref.read(mockDatabaseProvider);
    if (dbState.appLockEnabled) {
      state = state.copyWith(lockState: LockState.locked, lastActiveTime: null);
    }
  }

  void unlock({bool fromBiometrics = false}) {
    if (fromBiometrics) {
      state = state.copyWith(lockState: LockState.unlocking);
    } else {
      state = state.copyWith(lockState: LockState.unlocked, lastActiveTime: null);
    }
  }

  void recordBackgroundTime() {
    final dbState = _ref.read(mockDatabaseProvider);
    if (dbState.appLockEnabled) {
      state = state.copyWith(lastActiveTime: DateTime.now());
    }
  }

  void handleAppResumed() {
    final dbState = _ref.read(mockDatabaseProvider);
    if (!dbState.appLockEnabled) {
      state = state.copyWith(lockState: LockState.unlocked);
      return;
    }

    // If we are currently unlocking from biometrics, complete the unlock on resume
    if (state.lockState == LockState.unlocking) {
      state = state.copyWith(lockState: LockState.unlocked, lastActiveTime: null);
      return;
    }

    // If cold start or state reset, force lock immediately
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
