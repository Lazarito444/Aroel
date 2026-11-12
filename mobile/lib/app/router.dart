import 'package:aroel/features/auth/account/account_screen.dart';
import 'package:aroel/features/auth/delete/delete_account_screen.dart';
import 'package:aroel/core/onboarding.dart';
import 'package:aroel/features/auth/onboarding/onboarding_screen.dart';
import 'package:aroel/features/auth/signin/sign_in_screen.dart';
import 'package:aroel/features/settings/settings_screen.dart';
import 'package:aroel/features/today/today_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The routes of the app.
///
/// There is no route that asks for an account: the onboarding offers one, the settings
/// hold one, and everything else works without (§5.1).
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const TodayScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (BuildContext context, GoRouterState state) =>
            const SignInScreen(mode: AuthMode.signIn),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (BuildContext context, GoRouterState state) =>
            const SignInScreen(mode: AuthMode.signUp),
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/account',
        builder: (BuildContext context, GoRouterState state) =>
            const AccountScreen(),
      ),
      GoRoute(
        path: '/settings/account/delete',
        builder: (BuildContext context, GoRouterState state) =>
            const DeleteAccountScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final OnboardingState onboarding = ref.read(onboardingControllerProvider);
      final String location = state.matchedLocation;

      if (!onboarding.completed && location != '/onboarding') {
        return '/onboarding';
      }
      if (onboarding.completed && location == '/onboarding') {
        return '/';
      }
      return null;
    },
  );

  ref.listen<OnboardingState>(onboardingControllerProvider, (
    OnboardingState? previous,
    OnboardingState next,
  ) {
    router.refresh();
  });

  return router;
});
