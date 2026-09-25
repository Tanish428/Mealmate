import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../../ui/auth/login_screen.dart';
import '../../ui/auth/signup_screen.dart';
import '../../ui/auth/role_selection_screen.dart';

// Onboarding
import '../../ui/member/join_mess_screen.dart';
import '../../ui/owner/create_mess_screen.dart';

// Shells
import '../../ui/owner/owner_main_shell.dart';
import '../../ui/member/member_main_shell.dart';

// Owner Screens
import '../../ui/owner/owner_dashboard_screen.dart';
import '../../ui/owner/menu_manager_screen.dart';
import '../../ui/owner/members_screen.dart';
import '../../ui/owner/mess_profile_screen.dart';

// Member Screens
import '../../ui/member/member_home_screen.dart';
import '../../ui/member/menu_view_screen.dart';
import '../../ui/member/attendance_toggle_screen.dart';
import '../../ui/member/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> ownerDashboardNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> memberHomeNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // Auth Flow
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/join-mess',
      builder: (context, state) => const JoinMessScreen(),
    ),
    GoRoute(
      path: '/create-mess',
      builder: (context, state) => const CreateMessScreen(),
    ),

    // Owner Flow Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return OwnerMainShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Dashboard
        StatefulShellBranch(
          navigatorKey: ownerDashboardNavigatorKey,
          routes: [
            GoRoute(
              path: '/owner/dashboard',
              builder: (context, state) => OwnerDashboardScreen(
                onNavigateToMenu: () => context.go('/owner/menu'),
                onNavigateToMembers: () => context.go('/owner/members'),
              ),
            ),
          ],
        ),
        // Branch 1: Menu
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/owner/menu',
              builder: (context, state) => const MenuManagerScreen(),
            ),
          ],
        ),
        // Branch 2: Members
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/owner/members',
              builder: (context, state) => const MembersScreen(),
            ),
          ],
        ),
        // Branch 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/owner/profile',
              builder: (context, state) => const MessProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Member Flow Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MemberMainShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          navigatorKey: memberHomeNavigatorKey,
          routes: [
            GoRoute(
              path: '/member/home',
              builder: (context, state) => MemberHomeScreen(key: memberHomeScreenKey,
                onNavigateToMenu: () => context.go('/member/menu'),
                onNavigateToAttendance: () => context.go('/member/attendance'),
                onNavigateToProfile: () => context.go('/member/profile'),
              ),
            ),
          ],
        ),
        // Branch 1: Menu
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/member/menu',
              builder: (context, state) => const MenuViewScreen(),
            ),
          ],
        ),
        // Branch 2: Attendance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/member/attendance',
              builder: (context, state) => const AttendanceToggleScreen(),
            ),
          ],
        ),
        // Branch 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/member/profile',
              builder: (context, state) => const ProfileScreen(),
            //dmkedm
            ),
          ],
        ),
      ],
    ),
  ],
);


