import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/change_password_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/budget/presentation/pages/budget_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/expenses/presentation/pages/add_expense_page.dart';
import '../features/expenses/presentation/pages/expense_details_page.dart';
import '../features/income/presentation/pages/add_income_page.dart';
import '../features/income/presentation/pages/income_details_page.dart';
import '../features/onboarding/presentation/pages/intro_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/settings/presentation/pages/about_page.dart';
import '../features/settings/presentation/pages/currency_page.dart';
import '../features/settings/presentation/pages/delete_profile_page.dart';
import '../features/settings/presentation/pages/notifications_settings_page.dart';
import '../features/settings/presentation/pages/payment_methods_page.dart';
import '../features/settings/presentation/pages/privacy_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/transactions/presentation/pages/add_chooser_page.dart';
import '../features/transactions/presentation/pages/transactions_page.dart';
import 'main_shell_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: IntroRoute.page),
        AutoRoute(page: WelcomeRoute.page),
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: ForgotPasswordRoute.page),
        AutoRoute(page: ChangePasswordRoute.page),
        AutoRoute(
          page: MainShellRoute.page,
          children: [
            AutoRoute(page: DashboardRoute.page, initial: true),
            AutoRoute(page: TransactionsRoute.page),
            AutoRoute(page: AddChooserRoute.page),
            AutoRoute(page: ReportsRoute.page),
            AutoRoute(page: SettingsRoute.page),
          ],
        ),
        AutoRoute(page: AddExpenseRoute.page),
        AutoRoute(page: EditExpenseRoute.page),
        AutoRoute(page: ExpenseDetailsRoute.page),
        AutoRoute(page: AddIncomeRoute.page),
        AutoRoute(page: EditIncomeRoute.page),
        AutoRoute(page: IncomeDetailsRoute.page),
        AutoRoute(page: CategoriesRoute.page),
        AutoRoute(page: BudgetRoute.page),
        AutoRoute(page: CurrencyRoute.page),
        AutoRoute(page: PaymentMethodsRoute.page),
        AutoRoute(page: NotificationsSettingsRoute.page),
        AutoRoute(page: PrivacyRoute.page),
        AutoRoute(page: AboutRoute.page),
        AutoRoute(page: DeleteProfileRoute.page),
        AutoRoute(page: EditProfileRoute.page),
      ];
}
