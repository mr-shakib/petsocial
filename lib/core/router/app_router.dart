import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/view/onboarding_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/auth/viewmodel/auth_viewmodel.dart';
import '../../features/home/view/home_page.dart';
import '../../features/story_create/view/select_pet_page.dart';
import '../../features/story_create/view/story_camera_page.dart';
import '../../features/story_create/view/story_preview_page.dart';
import '../../features/story_view/view/story_viewer_page.dart';
import '../network/auth_event_notifier.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  final initiallyAuth = ref.read(initiallyAuthenticatedProvider);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: initiallyAuth ? '/home' : '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/story/select-pet',
        builder: (_, __) => const SelectPetPage(),
      ),
      GoRoute(
        path: '/story/camera',
        builder: (_, state) => StoryCameraPage(petId: state.extra as String),
      ),
      GoRoute(
        path: '/story/preview',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return StoryPreviewPage(
            petId: extra['petId'] as String,
            filePath: extra['filePath'] as String,
            isVideo: extra['isVideo'] as bool,
          );
        },
      ),
      GoRoute(
        path: '/story/viewer',
        builder: (_, state) =>
            StoryViewerPage(data: state.extra as StoryViewData),
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
    AuthEventNotifier.instance.addListener(_onUnauthorized);
  }

  final Ref _ref;

  void _onUnauthorized() {
    _ref.read(authProvider.notifier).logout();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = _ref.read(authProvider).isAuthenticated;
    final path = state.uri.path;
    final isOnAuthPages = path == '/' || path == '/login';

    if (!isAuthenticated && !isOnAuthPages) return '/';
    if (isAuthenticated && isOnAuthPages) return '/home';
    return null;
  }

  @override
  void dispose() {
    AuthEventNotifier.instance.removeListener(_onUnauthorized);
    super.dispose();
  }
}
