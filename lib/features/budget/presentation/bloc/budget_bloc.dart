import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/category_usecases.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/budget_usecases.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc({
    required GetBudgetsUseCase getBudgets,
    required UpsertBudgetUseCase upsertBudget,
    required DeleteBudgetUseCase deleteBudget,
    required GetCategoriesUseCase getCategories,
    required PreferencesDataSource preferences,
    required DataRefreshBus refreshBus,
  })  : _getBudgets = getBudgets,
        _upsertBudget = upsertBudget,
        _deleteBudget = deleteBudget,
        _getCategories = getCategories,
        _preferences = preferences,
        _refreshBus = refreshBus,
        super(BudgetState(
          month: DateTime.now().month,
          year: DateTime.now().year,
        )) {
    on<BudgetStarted>(_onStarted);
    on<BudgetPeriodChanged>(_onPeriodChanged);
    on<BudgetUpserted>(_onUpserted);
    on<BudgetDeleted>(_onDeleted);
    _subscription = _refreshBus.stream.listen((_) {
      if (!isClosed) add(const BudgetStarted());
    });
  }

  final GetBudgetsUseCase _getBudgets;
  final UpsertBudgetUseCase _upsertBudget;
  final DeleteBudgetUseCase _deleteBudget;
  final GetCategoriesUseCase _getCategories;
  final PreferencesDataSource _preferences;
  final DataRefreshBus _refreshBus;
  final _uuid = const Uuid();
  StreamSubscription<void>? _subscription;

  Future<void> _onStarted(
    BudgetStarted event,
    Emitter<BudgetState> emit,
  ) async {
    await _load(emit, state.month, state.year);
  }

  Future<void> _onPeriodChanged(
    BudgetPeriodChanged event,
    Emitter<BudgetState> emit,
  ) async {
    await _load(emit, event.month, event.year);
  }

  Future<void> _load(
    Emitter<BudgetState> emit,
    int month,
    int year,
  ) async {
    emit(
        state.copyWith(status: BudgetStatus.loading, month: month, year: year));
    final currency = await _preferences.getCurrencyCode();
    final categoriesResult = await _getCategories();
    final budgetsResult = await _getBudgets(month: month, year: year);

    if (categoriesResult.isFailure) {
      emit(
        state.copyWith(
          status: BudgetStatus.failure,
          errorMessage: categoriesResult.failureOrNull!.message,
        ),
      );
      return;
    }

    budgetsResult.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: BudgetStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (budgets) => emit(
        state.copyWith(
          status: BudgetStatus.success,
          budgets: budgets,
          categories: categoriesResult.dataOrNull,
          currencyCode: currency,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onUpserted(
    BudgetUpserted event,
    Emitter<BudgetState> emit,
  ) async {
    final now = DateTime.now();
    final budget = Budget(
      id: _uuid.v4(),
      month: state.month,
      year: state.year,
      amount: event.amount,
      categoryId: event.categoryId,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _upsertBudget(budget);
    result.fold(
      onFailure: (f) => emit(state.copyWith(errorMessage: f.message)),
      onSuccess: (_) => add(const BudgetStarted()),
    );
  }

  Future<void> _onDeleted(
    BudgetDeleted event,
    Emitter<BudgetState> emit,
  ) async {
    final result = await _deleteBudget(event.id);
    result.fold(
      onFailure: (f) => emit(state.copyWith(errorMessage: f.message)),
      onSuccess: (_) => add(const BudgetStarted()),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
