import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/token_service.dart';
import '../../../core/utils/error_parser.dart';
import '../repository/auth_repository.dart';

/// Seeded in main() before ProviderScope is created so the router can set
/// the correct initialLocation without an async gap (avoiding login flash).
final initiallyAuthenticatedProvider = Provider<bool>((_) => false);

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
  AuthState build() {
    final isAuth = ref.read(initiallyAuthenticatedProvider);
    return AuthState(isAuthenticated: isAuth);
  }

  Future<bool> login(String loginIdentifier, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(loginIdentifier, password);
      await TokenService.saveToken(result.token);
      await TokenService.saveUserId(result.id);
      await TokenService.saveProfilePictureUrl(result.profilePictureUrl);
      if (result.refreshToken != null) {
        await TokenService.saveRefreshToken(result.refreshToken!);
      }
      state = state.copyWith(isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ErrorParser.parseLogin(e));
      return false;
    }
  }

  Future<void> logout() async {
    await TokenService.clear();
    state = state.copyWith(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
