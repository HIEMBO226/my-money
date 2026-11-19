import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/extensions/context_extensions.dart';
import '../domain/entities/account.dart';
import '../domain/entities/recurring_transaction.dart';
import '../domain/entities/savings_goal.dart';
import '../domain/entities/transaction.dart';
import '../features/accounts/screens/account_form_screen.dart';
import '../features/accounts/screens/accounts_list_screen.dart';
import '../features/budgets/screens/budgets_screen.dart';
import '../features/categories/screens/categories_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/goals/screens/goal_form_screen.dart';
import '../features/goals/screens/goals_list_screen.dart';
import '../features/recurring/screens/recurring_form_screen.dart';
import '../features/recurring/screens/recurring_transactions_screen.dart';
import '../features/settings/screens/export_import_screen.dart';
import '../features/settings/screens/pin_setup_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/statistics/screens/statistics_screen.dart';
import '../features/transactions/screens/transaction_form_screen.dart';
import '../features/transactions/screens/transactions_list_screen.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: RouteNames.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              name: RouteNames.transactions,
              builder: (context, state) => const TransactionsListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/budgets',
              name: RouteNames.budgets,
              builder: (context, state) => const BudgetsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              name: RouteNames.statistics,
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: RouteNames.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/transactions/form',
      name: RouteNames.transactionForm,
      builder: (context, state) {
        final existing =
            state.extra is Transaction ? state.extra! as Transaction : null;
        return TransactionFormScreen(existingTransaction: existing);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/accounts',
      name: RouteNames.accounts,
      builder: (context, state) => const AccountsListScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/accounts/form',
      name: RouteNames.accountForm,
      builder: (context, state) {
        final existing = state.extra is Account ? state.extra! as Account : null;
        return AccountFormScreen(existingAccount: existing);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/categories',
      name: RouteNames.categories,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/recurring',
      name: RouteNames.recurring,
      builder: (context, state) => const RecurringTransactionsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/recurring/form',
      name: RouteNames.recurringForm,
      builder: (context, state) {
        final existing = state.extra is RecurringTransaction
            ? state.extra! as RecurringTransaction
            : null;
        return RecurringFormScreen(existing: existing);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/goals',
      name: RouteNames.goals,
      builder: (context, state) => const GoalsListScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/goals/form',
      name: RouteNames.goalForm,
      builder: (context, state) {
        final existing =
            state.extra is SavingsGoal ? state.extra! as SavingsGoal : null;
        return GoalFormScreen(existingGoal: existing);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings/export',
      name: RouteNames.exportImport,
      builder: (context, state) => const ExportImportScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings/security',
      name: RouteNames.pinSetup,
      builder: (context, state) => const PinSetupScreen(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        heroTag: 'addTransaction',
        onPressed: () => context.pushNamed(RouteNames.transactionForm),
        tooltip: l10n.addTransaction,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l10n.navBudgets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navStatistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
