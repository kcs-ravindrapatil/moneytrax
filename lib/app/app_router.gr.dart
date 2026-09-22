// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AboutPage]
class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute({List<PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutPage();
    },
  );
}

/// generated route for
/// [AddChooserPage]
class AddChooserRoute extends PageRouteInfo<void> {
  const AddChooserRoute({List<PageRouteInfo>? children})
    : super(AddChooserRoute.name, initialChildren: children);

  static const String name = 'AddChooserRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddChooserPage();
    },
  );
}

/// generated route for
/// [AddExpensePage]
class AddExpenseRoute extends PageRouteInfo<void> {
  const AddExpenseRoute({List<PageRouteInfo>? children})
    : super(AddExpenseRoute.name, initialChildren: children);

  static const String name = 'AddExpenseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddExpensePage();
    },
  );
}

/// generated route for
/// [AddIncomePage]
class AddIncomeRoute extends PageRouteInfo<void> {
  const AddIncomeRoute({List<PageRouteInfo>? children})
    : super(AddIncomeRoute.name, initialChildren: children);

  static const String name = 'AddIncomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddIncomePage();
    },
  );
}

/// generated route for
/// [BudgetPage]
class BudgetRoute extends PageRouteInfo<void> {
  const BudgetRoute({List<PageRouteInfo>? children})
    : super(BudgetRoute.name, initialChildren: children);

  static const String name = 'BudgetRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BudgetPage();
    },
  );
}

/// generated route for
/// [CategoriesPage]
class CategoriesRoute extends PageRouteInfo<void> {
  const CategoriesRoute({List<PageRouteInfo>? children})
    : super(CategoriesRoute.name, initialChildren: children);

  static const String name = 'CategoriesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategoriesPage();
    },
  );
}

/// generated route for
/// [ChangePasswordPage]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordPage();
    },
  );
}

/// generated route for
/// [CurrencyPage]
class CurrencyRoute extends PageRouteInfo<void> {
  const CurrencyRoute({List<PageRouteInfo>? children})
    : super(CurrencyRoute.name, initialChildren: children);

  static const String name = 'CurrencyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CurrencyPage();
    },
  );
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardPage();
    },
  );
}

/// generated route for
/// [DeleteProfilePage]
class DeleteProfileRoute extends PageRouteInfo<void> {
  const DeleteProfileRoute({List<PageRouteInfo>? children})
    : super(DeleteProfileRoute.name, initialChildren: children);

  static const String name = 'DeleteProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DeleteProfilePage();
    },
  );
}

/// generated route for
/// [EditExpensePage]
class EditExpenseRoute extends PageRouteInfo<EditExpenseRouteArgs> {
  EditExpenseRoute({
    Key? key,
    required String expenseId,
    List<PageRouteInfo>? children,
  }) : super(
         EditExpenseRoute.name,
         args: EditExpenseRouteArgs(key: key, expenseId: expenseId),
         initialChildren: children,
       );

  static const String name = 'EditExpenseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditExpenseRouteArgs>();
      return EditExpensePage(key: args.key, expenseId: args.expenseId);
    },
  );
}

class EditExpenseRouteArgs {
  const EditExpenseRouteArgs({this.key, required this.expenseId});

  final Key? key;

  final String expenseId;

  @override
  String toString() {
    return 'EditExpenseRouteArgs{key: $key, expenseId: $expenseId}';
  }
}

/// generated route for
/// [EditIncomePage]
class EditIncomeRoute extends PageRouteInfo<EditIncomeRouteArgs> {
  EditIncomeRoute({
    Key? key,
    required String incomeId,
    List<PageRouteInfo>? children,
  }) : super(
         EditIncomeRoute.name,
         args: EditIncomeRouteArgs(key: key, incomeId: incomeId),
         initialChildren: children,
       );

  static const String name = 'EditIncomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditIncomeRouteArgs>();
      return EditIncomePage(key: args.key, incomeId: args.incomeId);
    },
  );
}

class EditIncomeRouteArgs {
  const EditIncomeRouteArgs({this.key, required this.incomeId});

  final Key? key;

  final String incomeId;

  @override
  String toString() {
    return 'EditIncomeRouteArgs{key: $key, incomeId: $incomeId}';
  }
}

/// generated route for
/// [EditProfilePage]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfilePage();
    },
  );
}

/// generated route for
/// [ExpenseDetailsPage]
class ExpenseDetailsRoute extends PageRouteInfo<ExpenseDetailsRouteArgs> {
  ExpenseDetailsRoute({
    Key? key,
    required String expenseId,
    List<PageRouteInfo>? children,
  }) : super(
         ExpenseDetailsRoute.name,
         args: ExpenseDetailsRouteArgs(key: key, expenseId: expenseId),
         initialChildren: children,
       );

  static const String name = 'ExpenseDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ExpenseDetailsRouteArgs>();
      return ExpenseDetailsPage(key: args.key, expenseId: args.expenseId);
    },
  );
}

class ExpenseDetailsRouteArgs {
  const ExpenseDetailsRouteArgs({this.key, required this.expenseId});

  final Key? key;

  final String expenseId;

  @override
  String toString() {
    return 'ExpenseDetailsRouteArgs{key: $key, expenseId: $expenseId}';
  }
}

/// generated route for
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [IncomeDetailsPage]
class IncomeDetailsRoute extends PageRouteInfo<IncomeDetailsRouteArgs> {
  IncomeDetailsRoute({
    Key? key,
    required String incomeId,
    List<PageRouteInfo>? children,
  }) : super(
         IncomeDetailsRoute.name,
         args: IncomeDetailsRouteArgs(key: key, incomeId: incomeId),
         initialChildren: children,
       );

  static const String name = 'IncomeDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<IncomeDetailsRouteArgs>();
      return IncomeDetailsPage(key: args.key, incomeId: args.incomeId);
    },
  );
}

class IncomeDetailsRouteArgs {
  const IncomeDetailsRouteArgs({this.key, required this.incomeId});

  final Key? key;

  final String incomeId;

  @override
  String toString() {
    return 'IncomeDetailsRouteArgs{key: $key, incomeId: $incomeId}';
  }
}

/// generated route for
/// [IntroPage]
class IntroRoute extends PageRouteInfo<void> {
  const IntroRoute({List<PageRouteInfo>? children})
    : super(IntroRoute.name, initialChildren: children);

  static const String name = 'IntroRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const IntroPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MainShellPage]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellPage();
    },
  );
}

/// generated route for
/// [NotificationsSettingsPage]
class NotificationsSettingsRoute extends PageRouteInfo<void> {
  const NotificationsSettingsRoute({List<PageRouteInfo>? children})
    : super(NotificationsSettingsRoute.name, initialChildren: children);

  static const String name = 'NotificationsSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationsSettingsPage();
    },
  );
}

/// generated route for
/// [PaymentMethodsPage]
class PaymentMethodsRoute extends PageRouteInfo<void> {
  const PaymentMethodsRoute({List<PageRouteInfo>? children})
    : super(PaymentMethodsRoute.name, initialChildren: children);

  static const String name = 'PaymentMethodsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PaymentMethodsPage();
    },
  );
}

/// generated route for
/// [PrivacyPage]
class PrivacyRoute extends PageRouteInfo<void> {
  const PrivacyRoute({List<PageRouteInfo>? children})
    : super(PrivacyRoute.name, initialChildren: children);

  static const String name = 'PrivacyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    Key? key,
    bool isEditing = false,
    List<PageRouteInfo>? children,
  }) : super(
         ProfileRoute.name,
         args: ProfileRouteArgs(key: key, isEditing: isEditing),
         initialChildren: children,
       );

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileRouteArgs>(
        orElse: () => const ProfileRouteArgs(),
      );
      return ProfilePage(key: args.key, isEditing: args.isEditing);
    },
  );
}

class ProfileRouteArgs {
  const ProfileRouteArgs({this.key, this.isEditing = false});

  final Key? key;

  final bool isEditing;

  @override
  String toString() {
    return 'ProfileRouteArgs{key: $key, isEditing: $isEditing}';
  }
}

/// generated route for
/// [ReportsPage]
class ReportsRoute extends PageRouteInfo<void> {
  const ReportsRoute({List<PageRouteInfo>? children})
    : super(ReportsRoute.name, initialChildren: children);

  static const String name = 'ReportsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReportsPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [TransactionsPage]
class TransactionsRoute extends PageRouteInfo<void> {
  const TransactionsRoute({List<PageRouteInfo>? children})
    : super(TransactionsRoute.name, initialChildren: children);

  static const String name = 'TransactionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TransactionsPage();
    },
  );
}

/// generated route for
/// [WelcomePage]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomePage();
    },
  );
}
