import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/expense_usecases.dart';

part 'expense_details_event.dart';
part 'expense_details_state.dart';

class ExpenseDetailsBloc
    extends Bloc<ExpenseDetailsEvent, ExpenseDetailsState> {
  ExpenseDetailsBloc({
    required GetExpenseByIdUseCase getExpenseById,
    required DeleteExpenseUseCase deleteExpense,
  })  : _getExpenseById = getExpenseById,
        _deleteExpense = deleteExpense,
        super(const ExpenseDetailsState()) {
    on<ExpenseDetailsStarted>(_onStarted);
    on<ExpenseDetailsDeleted>(_onDeleted);
  }

  final GetExpenseByIdUseCase _getExpenseById;
  final DeleteExpenseUseCase _deleteExpense;

  Future<void> _onStarted(
    ExpenseDetailsStarted event,
    Emitter<ExpenseDetailsState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseDetailsStatus.loading));
    final result = await _getExpenseById(event.id);
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: ExpenseDetailsStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (expense) => emit(
        state.copyWith(
          status: ExpenseDetailsStatus.success,
          expense: expense,
        ),
      ),
    );
  }

  Future<void> _onDeleted(
    ExpenseDetailsDeleted event,
    Emitter<ExpenseDetailsState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseDetailsStatus.deleting));
    final result = await _deleteExpense(event.id);
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: ExpenseDetailsStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (_) =>
          emit(state.copyWith(status: ExpenseDetailsStatus.deleted)),
    );
  }
}
