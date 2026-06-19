import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitor {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  NetworkMonitor() {
    _connectivity.onConnectivityChanged.listen((result) {
      _controller.add(_isConnected(result));
    });
  }

  Stream<bool> get isConnectedStream => _controller.stream;

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  bool _isConnected(dynamic result) {
    if (result is Iterable) {
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    }
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    return false;
  }
}
