import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/token_service.dart';
import '../repository/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({bool? isLoading, String? error, bool? isAuthenticated}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(String loginIdentifier, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(loginIdentifier, password);
      await TokenService.saveToken(result.token);
      await TokenService.saveUserId(result.id);
      await TokenService.saveProfilePictureUrl(result.profilePictureUrl);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      final msg = _parseError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  String _parseError(Object e) {
    if (e is Exception) return e.toString().replaceFirst('Exception: ', '');
    return 'Login failed. Please check your credentials.';
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
