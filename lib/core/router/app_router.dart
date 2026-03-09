import 'package:go_router/go_router.dart';
import '../../features/onboarding/view/onboarding_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
