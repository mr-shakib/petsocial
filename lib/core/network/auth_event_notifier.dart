import 'package:flutter/foundation.dart';

/// Singleton ChangeNotifier that fires when the session is invalidated (401).
/// Used as a bridge between the Dio interceptor and the router/auth notifier
/// without creating circular Riverpod dependencies.
class AuthEventNotifier extends ChangeNotifier {
  AuthEventNotifier._();
  static final AuthEventNotifier instance = AuthEventNotifier._();

  void onUnauthorized() => notifyListeners();
}
