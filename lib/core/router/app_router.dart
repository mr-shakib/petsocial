import 'package:go_router/go_router.dart';
import '../../features/onboarding/view/onboarding_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/story_create/view/select_pet_page.dart';
import '../../features/story_create/view/story_camera_page.dart';
import '../../features/story_create/view/story_preview_page.dart';
import '../../features/story_view/view/story_viewer_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
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
