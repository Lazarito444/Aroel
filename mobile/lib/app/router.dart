import 'package:aroel/core/onboarding.dart';
import 'package:aroel/features/auth/account/account_screen.dart';
import 'package:aroel/features/auth/delete/delete_account_screen.dart';
import 'package:aroel/features/auth/onboarding/onboarding_screen.dart';
import 'package:aroel/features/auth/signin/sign_in_screen.dart';
import 'package:aroel/features/day/day_detail_screen.dart';
import 'package:aroel/features/entries/entry_read_screen.dart';
import 'package:aroel/features/insights/insights_screen.dart';
import 'package:aroel/features/notes/note_editor_screen.dart';
import 'package:aroel/features/notes/notes_list_screen.dart';
import 'package:aroel/features/settings/settings_screen.dart';
import 'package:aroel/features/today/today_screen.dart';
import 'package:aroel/features/today/write_screen.dart';
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
        builder: (BuildContext context, GoRouterState state) => const TodayScreen(),
      ),
      GoRoute(
        path: '/write',
        builder: (BuildContext context, GoRouterState state) => WriteScreen(localDate: state.uri.queryParameters['date']),
      ),
      GoRoute(
        path: '/notes',
        builder: (BuildContext context, GoRouterState state) => const NotesListScreen(),
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (BuildContext context, GoRouterState state) => NoteEditorScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/day/:localDate',
        builder: (BuildContext context, GoRouterState state) => DayDetailScreen(localDate: state.pathParameters['localDate']!),
      ),
      GoRoute(
        path: '/entry/:id',
        builder: (BuildContext context, GoRouterState state) => EntryReadScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/insights',
        builder: (BuildContext context, GoRouterState state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (BuildContext context, GoRouterState state) => const SignInScreen(mode: AuthMode.signIn),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (BuildContext context, GoRouterState state) => const SignInScreen(mode: AuthMode.signUp),
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/account',
        builder: (BuildContext context, GoRouterState state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/settings/account/delete',
        builder: (BuildContext context, GoRouterState state) => const DeleteAccountScreen(),
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
