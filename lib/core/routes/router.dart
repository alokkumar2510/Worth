import 'package:flutter/material.dart' hide LockState;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_colors.dart';
import '../constants/asset_paths.dart';
import '../providers/dependency_provider.dart';
import '../../features/accounts/domain/entities/account.dart' as domain;
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/portfolio/portfolio_screen.dart';
import '../../features/portfolio/presentation/screens/asset_detail_screen.dart';
import '../../features/portfolio/presentation/screens/investment_detail_screen.dart';
import '../../features/portfolio/presentation/screens/receivable_detail_screen.dart';
import '../../features/portfolio/presentation/screens/liability_detail_screen.dart';
import '../../features/portfolio/presentation/screens/expected_income_detail_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/reports/presentation/screens/snapshot_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/advanced_settings_screen.dart';
import '../../features/settings/presentation/screens/founder_screen.dart';
import '../../features/settings/presentation/screens/whats_new_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/ipo_pool/presentation/screens/ipo_dashboard_screen.dart';
import '../../features/ipo_pool/presentation/screens/ipo_detail_screen.dart';
import '../../features/ipo_pool/presentation/screens/ipo_contributors_list_screen.dart';
import '../../features/ipo_pool/presentation/screens/contributor_profile_screen.dart';
import '../../features/ipo_pool/presentation/screens/ipo_archive_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/definitions/presentation/screens/definitions_screen.dart';
import '../../features/portfolio/presentation/screens/goal_detail_screen.dart';
import '../../features/onboarding/presentation/screens/notification_permission_screen.dart';
import '../providers/app_lock_provider.dart';
import '../providers/mock_database.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/portfolio/presentation/screens/sip_dashboard_screen.dart';
import '../../features/checkins/presentation/screens/check_in_settings_screen.dart';
import '../../features/spending/presentation/screens/spending_screen.dart';
import '../../features/portfolio/presentation/screens/mtf_detail_screen.dart';
import '../../features/settings/presentation/screens/categories_labels_screen.dart';
import '../../features/settings/presentation/screens/archive_center_screen.dart';
import '../../features/history/presentation/screens/portfolio_history_archive_screen.dart';
import '../../features/recovery/presentation/screens/recovery_allocation_report_screen.dart';
import '../../features/settings/presentation/screens/financial_calculation_inspector_screen.dart';
import '../../features/recovery/presentation/screens/debt_recovery_dashboard_screen.dart';
import '../../features/recovery/presentation/screens/upi_settings_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _rootNavigatorKey = rootNavigatorKey;

CustomTransitionPage<T> buildPremiumTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.08);
      const end = Offset.zero;
      const curve = Curves.easeOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut));
      var scaleTween = Tween<double>(begin: 0.96, end: 1.0).chain(CurveTween(curve: Curves.easeOutQuart));

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: ScaleTransition(
          scale: animation.drive(scaleTween),
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 220),
  );
}

class NavigationShellScreen extends StatelessWidget {
  const NavigationShellScreen({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        elevation: 8,
        shadowColor: isDark ? Colors.black : Colors.black12,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: SvgPicture.asset(
              AssetPaths.icDashboard,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white60 : Colors.black54,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              AssetPaths.icDashboard,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.darkPrimary,
                BlendMode.srcIn,
              ),
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              AssetPaths.icPortfolio,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white60 : Colors.black54,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              AssetPaths.icPortfolio,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.darkPrimary,
                BlendMode.srcIn,
              ),
            ),
            label: 'Portfolio',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              AssetPaths.icTransactions,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white60 : Colors.black54,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              AssetPaths.icTransactions,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.darkPrimary,
                BlendMode.srcIn,
              ),
            ),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              AssetPaths.icReports,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white60 : Colors.black54,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              AssetPaths.icReports,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.darkPrimary,
                BlendMode.srcIn,
              ),
            ),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              AssetPaths.icSettings,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white60 : Colors.black54,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              AssetPaths.icSettings,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.darkPrimary,
                BlendMode.srcIn,
              ),
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RouterNotifier — bridges Riverpod to GoRouter's ChangeNotifier / listenable
// This pattern creates ONE GoRouter instance for the app lifetime and refreshes
// it when auth or account state changes, rather than rebuilding the GoRouter.
// ─────────────────────────────────────────────────────────────────────────────
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  // Track state to avoid infinite notifications
  AsyncValue<User?> _authState = const AsyncValue.loading();
  AsyncValue<List<domain.Account>> _accountsState = const AsyncValue.loading();

  RouterNotifier(this._ref);

  void updateAuthState(AsyncValue<User?> next) {
    if (_authState != next) {
      _authState = next;
      notifyListeners();
    }
  }

  void updateAccountsState(AsyncValue<List<domain.Account>> next) {
    if (_accountsState != next) {
      _accountsState = next;
      notifyListeners();
    }
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.matchedLocation;
    final dbState = _ref.read(mockDatabaseProvider);

    final isRestoring = _ref.read(isRestoringProvider);
    if (isRestoring) {
      debugPrint('[ROUTING] Data restore in progress. Blocking redirection.');
      return null;
    }

    // Auth state is still loading — stay on splash, do NOT redirect in a loop
    // Return null so the user sees the SplashScreen while we wait.
    if (_authState.isLoading) {
      if (path == '/') return null; // already on splash, wait
      debugPrint('[ROUTING] Navigation executed: Redirecting to / (splash)');
      return '/'; // redirect to splash while auth resolves
    }

    final user = _authState.value;
    final isLoggedIn = user != null;
    final onboardingCompleted = dbState.onboardingCompleted;

    if (!isLoggedIn) {
      if (!onboardingCompleted) {
        if (path == '/onboarding') return null;
        debugPrint('[ROUTING] Navigation executed: Redirecting to /onboarding');
        return '/onboarding';
      }
      if (path == '/login') return null;
      debugPrint('[ROUTING] Navigation executed: Redirecting to /login');
      return '/login';
    }

    if (!onboardingCompleted) {
      if (path == '/onboarding') return null;
      debugPrint('[ROUTING] Navigation executed: Redirecting to /onboarding');
      return '/onboarding';
    }

    // Redirect to notification onboarding before dashboard if not asked yet
    if (!dbState.notificationsAsked) {
      if (path == '/notifications_onboarding') return null;
      debugPrint('[ROUTING] Navigation executed: Redirecting to /notifications_onboarding');
      return '/notifications_onboarding';
    }

    // Fully authenticated with onboarding completed: redirect away from auth/onboarding screens
    if (path == '/' || path == '/login' || path == '/onboarding' || path == '/notifications_onboarding') {
      debugPrint('[ROUTING] Navigation executed: Redirecting to /dashboard');
      return '/dashboard';
    }

    return null; // allow navigation
  }
}

final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);

  ref.listen<AsyncValue<User?>>(
    authStateChangesProvider,
    (_, next) {
      notifier.updateAuthState(next);
    },
    fireImmediately: true,
  );

  ref.listen<AsyncValue<List<domain.Account>>>(
    activeAccountsProvider,
    (_, next) {
      notifier.updateAccountsState(next);
    },
    fireImmediately: true,
  );

  ref.listen<MockDatabaseState>(
    mockDatabaseProvider,
    (_, next) {
      notifier.notifyListeners();
    },
    fireImmediately: true,
  );

  ref.listen<bool>(
    isRestoringProvider,
    (_, next) {
      notifier.notifyListeners();
    },
    fireImmediately: true,
  );

  return notifier;
});

// The GoRouter is created ONCE as a Provider. It uses RouterNotifier as
// its refreshListenable so navigation is re-evaluated when auth changes.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: <RouteBase>[
      // Splash Screen Route
      GoRoute(
        path: '/',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      // Login, Onboarding & Notification permission Routes
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications_onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const NotificationPermissionScreen(),
        ),
      ),

      // Global Search Screen
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const SearchScreen(),
        ),
      ),

      // Definitions Center Screen
      GoRoute(
        path: '/definitions',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const DefinitionsScreen(),
        ),
      ),

      // Debt Recovery Dashboard Screen
      GoRoute(
        path: '/recovery/dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const DebtRecoveryDashboardScreen(),
        ),
      ),

      // UPI settings Screen
      GoRoute(
        path: '/recovery/upi_settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const UpiSettingsScreen(),
        ),
      ),

      // Monthly Snapshots Screen
      GoRoute(
        path: '/monthly_snapshot',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const SnapshotScreen(),
        ),
      ),

      // Profile Information Screen
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const ProfileScreen(),
        ),
      ),

      // SIP Automation Dashboard Screen
      GoRoute(
        path: '/sip',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const SipDashboardScreen(),
        ),
      ),

      // Achievements Center Screen
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const AchievementsScreen(),
        ),
      ),

      // Spending Intelligence Screen
      GoRoute(
        path: '/spending',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => buildPremiumTransitionPage(
          state: state,
          child: const SpendingScreen(),
        ),
      ),

      // Shell Route for Bottom Nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShellScreen(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Branch 1: Dashboard
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 2: Portfolio
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/portfolio',
                builder: (context, state) => const PortfolioScreen(),
                routes: [
                  GoRoute(
                    path: 'asset/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return buildPremiumTransitionPage(
                        state: state,
                        child: AssetDetailScreen(accountId: id),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'investment/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return buildPremiumTransitionPage(
                        state: state,
                        child: InvestmentDetailScreen(investmentId: id),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'receivable/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return buildPremiumTransitionPage(
                        state: state,
                        child: ReceivableDetailScreen(personId: id),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'liability/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return buildPremiumTransitionPage(
                        state: state,
                        child: LiabilityDetailScreen(id: id),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'expected/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return buildPremiumTransitionPage(
                        state: state,
                        child: ExpectedIncomeDetailScreen(incomeId: id),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'goal/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return buildPremiumTransitionPage(
                        state: state,
                        child: GoalDetailScreen(goalId: id),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'mtf/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return buildPremiumTransitionPage(
                        state: state,
                        child: MtfDetailScreen(mtfPositionId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Transactions
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),

          // Branch 4: Reports
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),

          // Branch 5: Settings (Labeled "More")
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'advanced',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const AdvancedSettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'founder',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const FounderScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'whats_new',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const WhatsNewScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'checkins',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const CheckInSettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'categories_labels',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const CategoriesLabelsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'archive_center',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const ArchiveCenterScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'ipo_pool',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const IpoDashboardScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'contributors',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) => buildPremiumTransitionPage(
                          state: state,
                          child: const IpoContributorsListScreen(),
                        ),
                        routes: [
                          GoRoute(
                            path: ':name',
                            parentNavigatorKey: _rootNavigatorKey,
                            pageBuilder: (context, state) {
                              final name = state.pathParameters['name']!;
                              return buildPremiumTransitionPage(
                                state: state,
                                child: ContributorProfileScreen(contributorName: name),
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'archive',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) => buildPremiumTransitionPage(
                          state: state,
                          child: const IpoArchiveScreen(),
                        ),
                      ),
                      GoRoute(
                        path: ':id',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return buildPremiumTransitionPage(
                            state: state,
                            child: IpoDetailScreen(ipoId: id),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'history_archive',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const PortfolioHistoryArchiveScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'recovery_report',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const RecoveryAllocationReportScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'calculation_inspector',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => buildPremiumTransitionPage(
                      state: state,
                      child: const FinancialCalculationInspectorScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
