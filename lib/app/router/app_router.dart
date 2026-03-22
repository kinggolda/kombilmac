import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schedule_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:schedule_app/features/schedule/domain/entities/lesson.dart';
import 'package:schedule_app/features/schedule/presentation/screens/event_details_screen.dart';
import 'package:schedule_app/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:schedule_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:schedule_app/features/splash/presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routeName,
        pageBuilder: (context, state) {
          return _transitionPage(state, const SplashScreen());
        },
      ),
      GoRoute(
        path: OnboardingScreen.routePath,
        name: OnboardingScreen.routeName,
        pageBuilder: (context, state) {
          return _transitionPage(state, const OnboardingScreen());
        },
      ),
      GoRoute(
        path: ScheduleScreen.routePath,
        name: ScheduleScreen.routeName,
        pageBuilder: (context, state) {
          return _transitionPage(state, const ScheduleScreen());
        },
      ),
      GoRoute(
        path: EventDetailsScreen.routePath,
        name: EventDetailsScreen.routeName,
        pageBuilder: (context, state) {
          final item = state.extra;
          if (item is! Lesson) {
            return _transitionPage(
              state,
              const RouteErrorScreen(message: 'Event payload is missing.'),
            );
          }

          return _transitionPage(state, EventDetailsScreen(lesson: item));
        },
      ),
      GoRoute(
        path: SettingsScreen.routePath,
        name: SettingsScreen.routeName,
        pageBuilder: (context, state) {
          return _transitionPage(state, const SettingsScreen());
        },
      ),
    ],
    errorPageBuilder: (context, state) {
      return _transitionPage(
        state,
        RouteErrorScreen(
          message: state.error?.toString() ?? 'Unknown navigation error.',
        ),
      );
    },
  );
});

CustomTransitionPage<void> _transitionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: pageChild,
        ),
      );
    },
  );
}

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

