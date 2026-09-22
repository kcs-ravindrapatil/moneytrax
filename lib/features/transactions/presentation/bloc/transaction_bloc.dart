import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/usecases/category_usecases.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required TransactionRepository transactionRepository,
    required GetCategoriesUseCase getCategories,
    required PreferencesDataSource preferences,
    required DataRefreshBus refreshBus,
  })  : _repository = transactionRepository,
        _getCategories = getCategories,
        _preferences = preferences,
        _refreshBus = refreshBus,
        super(const TransactionState()) {
    on<TransactionStarted>(_onLoad);
    on<TransactionSearchChanged>(_onSearch);
    on<TransactionTypeFilterChanged>(_onType);
    on<TransactionCategoryFilterChanged>(_onCategory);
    on<TransactionDateRangeChanged>(_onDateRange);
    on<TransactionSortChanged>(_onSort);
    on<TransactionRefreshed>(_onLoad);
    _subscription = _refreshBus.stream.listen((_) {
      if (!isClosed) add(const TransactionRefreshed());
    });
  }

  final TransactionRepository _repository;
  final GetCategoriesUseCase _getCategories;
  final PreferencesDataSource _preferences;
  final DataRefreshBus _refreshBus;
  StreamSubscription<void>? _subscription;

  Future<void> _onLoad(
    TransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    final categoriesResult = await _getCategories();
    final currency = await _preferences.getCurrencyCode();
    final result = await _repository.getTransactions(
      search: state.search,
      type: state.filterType,
      categoryId: state.categoryId,
      from: state.from,
      to: state.to,
      sortBy: state.sortBy,
      ascending: state.ascending,
    );

    if (categoriesResult.isFailure) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: categoriesResult.failureOrNull!.message,
        ),
      );
      return;
    }

    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (items) => emit(
        state.copyWith(
          status: items.isEmpty
              ? TransactionStatus.empty
              : TransactionStatus.success,
          items: items,
          categories: categoriesResult.dataOrNull,
          currencyCode: currency,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onSearch(
    TransactionSearchChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(search: event.query));
    add(const TransactionRefreshed());
  }

  Future<void> _onType(
    TransactionTypeFilterChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        filterType: event.type,
        clearCategoryId: true,
      ),
    );
    add(const TransactionRefreshed());
  }

  Future<void> _onCategory(
    TransactionCategoryFilterChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        categoryId: event.categoryId,
        clearCategoryId: event.categoryId == null,
      ),
    );
    add(const TransactionRefreshed());
  }

  Future<void> _onDateRange(
    TransactionDateRangeChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        from: event.from,
        to: event.to,
        clearDateRange: event.clear,
      ),
    );
    add(const TransactionRefreshed());
  }

  Future<void> _onSort(
    TransactionSortChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(sortBy: event.sortBy, ascending: event.ascending));
    add(const TransactionRefreshed());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
