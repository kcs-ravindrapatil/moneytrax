import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:conveygrid_moneytracker/core/result/result.dart';
import 'package:conveygrid_moneytracker/features/categories/domain/entities/category.dart';
import 'package:conveygrid_moneytracker/features/categories/domain/usecases/category_usecases.dart';
import 'package:conveygrid_moneytracker/features/expenses/domain/usecases/expense_usecases.dart';
import 'package:conveygrid_moneytracker/features/expenses/presentation/bloc/expense_form_bloc.dart';
import 'package:conveygrid_moneytracker/features/settings/data/datasources/preferences_data_source.dart';

class _MockAdd extends Mock implements AddExpenseUseCase {}

class _MockUpdate extends Mock implements UpdateExpenseUseCase {}

class _MockGetById extends Mock implements GetExpenseByIdUseCase {}

class _MockGetCategories extends Mock implements GetCategoriesUseCase {}

class _MockPrefs extends Mock implements PreferencesDataSource {}

void main() {
  late _MockGetCategories getCategories;
  late _MockPrefs prefs;

  setUp(() {
    getCategories = _MockGetCategories();
    prefs = _MockPrefs();
    when(() => getCategories()).thenAnswer(
      (_) async => Success([
        Category(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          isDefault: true,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ]),
    );
    when(() => prefs.getPaymentMethods())
        .thenAnswer((_) async => ['Cash', 'UPI']);
  });

  blocTest<ExpenseFormBloc, ExpenseFormState>(
    'loads categories and payment methods for add expense form',
    build: () => ExpenseFormBloc(
      addExpense: _MockAdd(),
      updateExpense: _MockUpdate(),
      getExpenseById: _MockGetById(),
      getCategories: getCategories,
      preferences: prefs,
    ),
    act: (bloc) => bloc.add(const ExpenseFormStarted()),
    expect: () => [
      isA<ExpenseFormState>()
          .having((s) => s.status, 'status', ExpenseFormStatus.loading),
      isA<ExpenseFormState>()
          .having((s) => s.status, 'status', ExpenseFormStatus.editing)
          .having((s) => s.categories.length, 'categories', 1)
          .having((s) => s.paymentMethods.length, 'methods', 2),
    ],
  );
}
