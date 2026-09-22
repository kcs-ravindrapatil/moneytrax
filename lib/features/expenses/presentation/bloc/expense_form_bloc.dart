import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/validators/app_validators.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/category_usecases.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/expense_usecases.dart';

part 'expense_form_event.dart';
part 'expense_form_state.dart';

class ExpenseFormBloc extends Bloc<ExpenseFormEvent, ExpenseFormState> {
  ExpenseFormBloc({
    required AddExpenseUseCase addExpense,
    required UpdateExpenseUseCase updateExpense,
    required GetExpenseByIdUseCase getExpenseById,
    required GetCategoriesUseCase getCategories,
    required PreferencesDataSource preferences,
    String? expenseId,
  })  : _addExpense = addExpense,
        _updateExpense = updateExpense,
        _getExpenseById = getExpenseById,
        _getCategories = getCategories,
        _preferences = preferences,
        _expenseId = expenseId,
        super(const ExpenseFormState()) {
    on<ExpenseFormStarted>(_onStarted);
    on<ExpenseAmountChanged>(_onAmountChanged);
    on<ExpenseCategoryChanged>(_onCategoryChanged);
    on<ExpenseDateChanged>(_onDateChanged);
    on<ExpensePaymentMethodChanged>(_onPaymentChanged);
    on<ExpenseNoteChanged>(_onNoteChanged);
    on<ExpenseFormSubmitted>(_onSubmitted);
  }

  final AddExpenseUseCase _addExpense;
  final UpdateExpenseUseCase _updateExpense;
  final GetExpenseByIdUseCase _getExpenseById;
  final GetCategoriesUseCase _getCategories;
  final PreferencesDataSource _preferences;
  final String? _expenseId;
  final _uuid = const Uuid();

  Future<void> _onStarted(
    ExpenseFormStarted event,
    Emitter<ExpenseFormState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseFormStatus.loading));
    final categoriesResult = await _getCategories();
    final methods = await _preferences.getPaymentMethods();

    if (categoriesResult.isFailure) {
      emit(
        state.copyWith(
          status: ExpenseFormStatus.failure,
          errorMessage: categoriesResult.failureOrNull!.message,
        ),
      );
      return;
    }

    final categories = categoriesResult.dataOrNull!;
    var next = state.copyWith(
      categories: categories,
      paymentMethods: methods,
      categoryId: categories.isNotEmpty ? categories.first.id : null,
      paymentMethod: methods.isNotEmpty ? methods.first : 'Cash',
      date: DateTime.now(),
      status: ExpenseFormStatus.editing,
    );

    if (_expenseId != null) {
      final expenseResult = await _getExpenseById(_expenseId);
      if (expenseResult.isFailure) {
        emit(
          state.copyWith(
            status: ExpenseFormStatus.failure,
            errorMessage: expenseResult.failureOrNull!.message,
          ),
        );
        return;
      }
      final e = expenseResult.dataOrNull!;
      next = next.copyWith(
        amount: e.amount.toString(),
        categoryId: e.categoryId,
        date: e.date,
        paymentMethod: e.paymentMethod,
        note: e.note ?? '',
        existingCreatedAt: e.createdAt,
        isValid: true,
      );
    }

    emit(next.copyWith(isValid: _isValid(next)));
  }

  void _onAmountChanged(
    ExpenseAmountChanged event,
    Emitter<ExpenseFormState> emit,
  ) {
    final next = state.copyWith(amount: event.value);
    emit(next.copyWith(isValid: _isValid(next), errorMessage: null));
  }

  void _onCategoryChanged(
    ExpenseCategoryChanged event,
    Emitter<ExpenseFormState> emit,
  ) {
    final next = state.copyWith(categoryId: event.categoryId);
    emit(next.copyWith(isValid: _isValid(next)));
  }

  void _onDateChanged(
    ExpenseDateChanged event,
    Emitter<ExpenseFormState> emit,
  ) {
    final next = state.copyWith(date: event.date);
    emit(next.copyWith(isValid: _isValid(next)));
  }

  void _onPaymentChanged(
    ExpensePaymentMethodChanged event,
    Emitter<ExpenseFormState> emit,
  ) {
    final next = state.copyWith(paymentMethod: event.method);
    emit(next.copyWith(isValid: _isValid(next)));
  }

  void _onNoteChanged(
    ExpenseNoteChanged event,
    Emitter<ExpenseFormState> emit,
  ) {
    emit(state.copyWith(note: event.value));
  }

  bool _isValid(ExpenseFormState s) {
    return AppValidators.amount(s.amount) == null &&
        (s.categoryId?.isNotEmpty ?? false) &&
        (s.paymentMethod?.isNotEmpty ?? false) &&
        s.date != null;
  }

  Future<void> _onSubmitted(
    ExpenseFormSubmitted event,
    Emitter<ExpenseFormState> emit,
  ) async {
    if (!_isValid(state)) {
      emit(state.copyWith(errorMessage: 'Please complete required fields.'));
      return;
    }
    emit(state.copyWith(status: ExpenseFormStatus.submitting));
    final now = DateTime.now();
    final expense = Expense(
      id: _expenseId ?? _uuid.v4(),
      amount: double.parse(state.amount),
      categoryId: state.categoryId!,
      date: state.date!,
      paymentMethod: state.paymentMethod!,
      note: state.note.trim().isEmpty ? null : state.note.trim(),
      createdAt: state.existingCreatedAt ?? now,
      updatedAt: now,
    );

    final result = _expenseId == null
        ? await _addExpense(expense)
        : await _updateExpense(expense);

    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: ExpenseFormStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (_) => emit(state.copyWith(status: ExpenseFormStatus.success)),
    );
  }
}
