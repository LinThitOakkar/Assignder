import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/assignment/screens/add_assignment_screen.dart';
import '../../features/assignment/screens/assignment_detail_screen.dart';
import '../../features/submitted/screens/submitted_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/notification_settings_screen.dart';
import '../../core/widgets/app_bottom_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  final authProvider = context.read<AuthProvider>();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == '/login' || location == '/register' || location == '/auth/forgot-password';

      if (status == AuthStatus.unknown) {
        return null;
      }

      if (status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/login';
      }

      if (status == AuthStatus.authenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const AuthScreen(initialTabIndex: 1),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ─── Shell Route (Bottom Nav) ──────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffoldWithBottomNav(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'add-assignment',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddAssignmentScreen(),
              ),
              GoRoute(
                path: 'assignment/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AssignmentDetailScreen(assignmentId: id);
                },
              ),
            ],
          ),

          // Submitted
          GoRoute(
            path: '/submitted',
            builder: (context, state) => const SubmittedScreen(),
            routes: [
              GoRoute(
                path: 'assignment/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AssignmentDetailScreen(assignmentId: id);
                },
              ),
            ],
          ),

          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) =>
                        const NotificationSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
