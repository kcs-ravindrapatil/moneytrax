import 'dart:async';

/// Broadcasts when local money data changes so list/dashboard BLoCs can refresh.
class DataRefreshBus {
  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notifyChanged() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
