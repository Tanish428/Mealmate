import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../../ui/auth/login_screen.dart';
import '../../ui/auth/signup_screen.dart';
import '../../ui/auth/role_selection_screen.dart';

// Onboarding
import '../../ui/member/join_mess_screen.dart';
import '../../ui/owner/mess creation/create_mess_screen.dart';

// Shells
import '../../ui/owner/owner_main_shell.dart';
import '../../ui/member/member_main_shell.dart';

// Owner Screens
import '../../ui/owner/dashboard/owner_dashboard_screen.dart';
import '../../ui/owner/menu/menu_manager_screen.dart';
import '../../ui/owner/members/members_screen.dart';
import '../../ui/owner/settings/mess_profile_screen.dart';

// Member Screens
import '../../ui/member/member_home_screen.dart';
import '../../ui/member/menu_view_screen.dart';
import '../../ui/member/announcements/notice_board_screen.dart';
import '../../ui/member/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

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
          routes: [
            GoRoute(
              path: '/owner/dashboard',
              builder: (context, state) => const OwnerDashboardScreen(),
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
          routes: [
            GoRoute(
              path: '/member/home',
              builder: (context, state) => const MemberHomeScreen(),
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
        // Branch 2: Notices
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/member/notices',
              builder: (context, state) => const NoticeBoardScreen(),
            ),
          ],
        ),
        // Branch 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/member/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
