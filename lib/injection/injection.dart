import 'package:conveygrid_flutter_sdk/conveygrid_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/theme/theme_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/change_password_bloc.dart';
import '../core/database/app_database.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/data_refresh_bus.dart';
import '../core/utils/notification_service.dart';
import '../features/budget/data/datasources/budget_local_data_source.dart';
import '../features/budget/data/repositories/budget_repository_impl.dart';
import '../features/budget/domain/repositories/budget_repository.dart';
import '../features/budget/domain/usecases/budget_usecases.dart';
import '../features/budget/presentation/bloc/budget_bloc.dart';
import '../features/categories/data/datasources/category_local_data_source.dart';
import '../features/categories/data/repositories/category_repository_impl.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/categories/domain/usecases/category_usecases.dart';
import '../features/categories/presentation/bloc/category_bloc.dart';
import '../features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/expenses/data/datasources/expense_local_data_source.dart';
import '../features/expenses/data/repositories/expense_repository_impl.dart';
import '../features/expenses/domain/repositories/expense_repository.dart';
import '../features/expenses/domain/usecases/expense_usecases.dart';
import '../features/expenses/presentation/bloc/expense_details_bloc.dart';
import '../features/expenses/presentation/bloc/expense_form_bloc.dart';
import '../features/income/data/datasources/income_local_data_source.dart';
import '../features/income/data/repositories/income_repository_impl.dart';
import '../features/income/domain/repositories/income_repository.dart';
import '../features/income/domain/usecases/income_usecases.dart';
import '../features/income/presentation/bloc/income_details_bloc.dart';
import '../features/income/presentation/bloc/income_form_bloc.dart';
import '../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../features/onboarding/presentation/bloc/splash_bloc.dart';
import '../features/profile/data/datasources/profile_local_data_source.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/profile_usecases.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/reports/data/services/invoice_pdf_service.dart';
import '../features/reports/domain/usecases/get_report_summary_usecase.dart';
import '../features/reports/presentation/bloc/report_bloc.dart';
import '../features/settings/data/datasources/preferences_data_source.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../integrations/consent/consent_integration.dart';
import '../integrations/consent/conveygrid_consent_integration.dart';
import '../integrations/consent/conveygrid_env.dart';
import '../integrations/consent/noop_consent_integration.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<AppDatabase>()) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerLazySingleton<SharedPreferences>(() => prefs)
    ..registerLazySingleton<PreferencesDataSource>(
      () => PreferencesDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AppDatabase>(AppDatabase.new)
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<DataRefreshBus>(DataRefreshBus.new)
    ..registerLazySingleton<InvoicePdfService>(InvoicePdfService.new)
    ..registerLazySingleton<ThemeBloc>(() => ThemeBloc(getIt()));

  await _registerConsentIntegration();

  // Data sources
  getIt
    ..registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<CategoryLocalDataSource>(
      () => CategoryLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ExpenseLocalDataSource>(
      () => ExpenseLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<IncomeLocalDataSource>(
      () => IncomeLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<BudgetLocalDataSource>(
      () => BudgetLocalDataSourceImpl(getIt()),
    );

  // Repositories
  getIt
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        localDataSource: getIt(),
        appDatabase: getIt(),
        preferences: getIt(),
        consentIntegration: getIt(),
      ),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<IncomeRepository>(
      () => IncomeRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        expenseRepository: getIt(),
        incomeRepository: getIt(),
      ),
    );

  // Use cases
  getIt
    ..registerLazySingleton(() => GetProfileUseCase(getIt()))
    ..registerLazySingleton(() => SaveProfileUseCase(getIt()))
    ..registerLazySingleton(() => UpdateProfileUseCase(getIt()))
    ..registerLazySingleton(() => LoginUseCase(getIt()))
    ..registerLazySingleton(() => UpdatePasswordUseCase(getIt()))
    ..registerLazySingleton(() => ResetPasswordUseCase(getIt()))
    ..registerLazySingleton(() => DeleteProfileUseCase(getIt()))
    ..registerLazySingleton(() => GetCategoriesUseCase(getIt()))
    ..registerLazySingleton(() => AddCategoryUseCase(getIt()))
    ..registerLazySingleton(() => UpdateCategoryUseCase(getIt()))
    ..registerLazySingleton(() => DeleteCategoryUseCase(getIt()))
    ..registerLazySingleton(() => GetExpensesUseCase(getIt()))
    ..registerLazySingleton(() => GetExpenseByIdUseCase(getIt()))
    ..registerLazySingleton(() => AddExpenseUseCase(getIt()))
    ..registerLazySingleton(() => UpdateExpenseUseCase(getIt()))
    ..registerLazySingleton(() => DeleteExpenseUseCase(getIt()))
    ..registerLazySingleton(() => GetIncomesUseCase(getIt()))
    ..registerLazySingleton(() => GetIncomeByIdUseCase(getIt()))
    ..registerLazySingleton(() => AddIncomeUseCase(getIt()))
    ..registerLazySingleton(() => UpdateIncomeUseCase(getIt()))
    ..registerLazySingleton(() => DeleteIncomeUseCase(getIt()))
    ..registerLazySingleton(() => GetBudgetsUseCase(getIt()))
    ..registerLazySingleton(() => UpsertBudgetUseCase(getIt()))
    ..registerLazySingleton(() => DeleteBudgetUseCase(getIt()))
    ..registerLazySingleton(
      () => GetReportSummaryUseCase(
        expenseRepository: getIt(),
        incomeRepository: getIt(),
        transactionRepository: getIt(),
      ),
    )
    ..registerLazySingleton(
      () => GetDashboardDataUseCase(
        profileRepository: getIt(),
        expenseRepository: getIt(),
        incomeRepository: getIt(),
        transactionRepository: getIt(),
        getCurrencyCode: () => getIt<PreferencesDataSource>().getCurrencyCode(),
      ),
    );

  // BLoCs (factories)
  getIt
    ..registerFactory(
      () => SplashBloc(getProfile: getIt(), preferences: getIt()),
    )
    ..registerFactory(() => OnboardingBloc(getIt()))
    ..registerFactory(
      () => ProfileBloc(
        saveProfile: getIt(),
        updateProfile: getIt(),
        getProfile: getIt(),
      ),
    )
    ..registerFactory(
      () => AuthBloc(
        login: getIt(),
        resetPassword: getIt(),
      ),
    )
    ..registerFactory(() => ChangePasswordBloc(getIt()))
    ..registerFactory(() => DashboardBloc(getIt(), getIt()))
    ..registerFactory(
      () => TransactionBloc(
        transactionRepository: getIt(),
        getCategories: getIt(),
        preferences: getIt(),
        refreshBus: getIt(),
      ),
    )
    ..registerFactoryParam<ExpenseFormBloc, String?, void>(
      (expenseId, _) => ExpenseFormBloc(
        addExpense: getIt(),
        updateExpense: getIt(),
        getExpenseById: getIt(),
        getCategories: getIt(),
        preferences: getIt(),
        expenseId: expenseId,
      ),
    )
    ..registerFactory(
      () => ExpenseDetailsBloc(
        getExpenseById: getIt(),
        deleteExpense: getIt(),
      ),
    )
    ..registerFactoryParam<IncomeFormBloc, String?, void>(
      (incomeId, _) => IncomeFormBloc(
        addIncome: getIt(),
        updateIncome: getIt(),
        getIncomeById: getIt(),
        incomeId: incomeId,
      ),
    )
    ..registerFactory(
      () => IncomeDetailsBloc(
        getIncomeById: getIt(),
        deleteIncome: getIt(),
      ),
    )
    ..registerFactory(
      () => CategoryBloc(
        getCategories: getIt(),
        addCategory: getIt(),
        updateCategory: getIt(),
        deleteCategory: getIt(),
      ),
    )
    ..registerFactory(
      () => ReportBloc(
        getReportSummary: getIt(),
        preferences: getIt(),
        getProfile: getIt(),
        invoicePdfService: getIt(),
        refreshBus: getIt(),
      ),
    )
    ..registerFactory(
      () => BudgetBloc(
        getBudgets: getIt(),
        upsertBudget: getIt(),
        deleteBudget: getIt(),
        getCategories: getIt(),
        preferences: getIt(),
        refreshBus: getIt(),
      ),
    )
    ..registerFactory(
      () => SettingsBloc(
        preferences: getIt(),
        notificationService: getIt(),
        deleteProfile: getIt(),
      ),
    );
}

Future<void> _registerConsentIntegration() async {
  if (!ConveyGridEnv.hasApplicationKey) {
    AppLogger.debug(
      'ConveyGrid application key missing — using NoOpConsentIntegration.',
    );
    getIt.registerLazySingleton<ConsentIntegration>(
      NoOpConsentIntegration.new,
    );
    return;
  }

  final client = ConveyGridClient(
    config: ConveyGridConfig(
      apiBaseUrl: ConveyGridEnv.apiBaseUrl,
      applicationKey: ConveyGridEnv.applicationKey,
      origin: ConveyGridEnv.dfOrigin,
      referer: ConveyGridEnv.dfReferer,
      sendOriginRefererHeaders: true,
      theme: const ConveyGridTheme(
        primaryColor: Color(0xFF0F766E),
        secondaryColor: Color(0xFF0F172A),
      ),
    ),
  );

  final initialized = await client.initialize();
  if (initialized.isFailure) {
    AppLogger.error(
      'ConveyGrid initialize failed — falling back to NoOpConsentIntegration.',
      initialized.failureOrNull?.message,
    );
    getIt.registerLazySingleton<ConsentIntegration>(
      NoOpConsentIntegration.new,
    );
    return;
  }

  getIt
    ..registerSingleton<ConveyGridClient>(client)
    ..registerLazySingleton<ConsentIntegration>(
      () => ConveyGridConsentIntegration(getIt()),
    );
}
