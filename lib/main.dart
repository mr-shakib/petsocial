import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'core/router/app_router.dart';
import 'core/services/token_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Check for a stored token before building the widget tree so the router
  // can set the correct initialLocation with no login flash on relaunch.
  final hasToken = await TokenService.getToken() != null;

  runApp(
    ProviderScope(
      overrides: [
        initiallyAuthenticatedProvider.overrideWithValue(hasToken),
      ],
      child: const PetSocialApp(),
    ),
  );
}

class PetSocialApp extends ConsumerWidget {
  const PetSocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PetSocial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
