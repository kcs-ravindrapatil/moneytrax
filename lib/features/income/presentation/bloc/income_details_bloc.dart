import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/income.dart';
import '../../domain/usecases/income_usecases.dart';

part 'income_details_event.dart';
part 'income_details_state.dart';

class IncomeDetailsBloc extends Bloc<IncomeDetailsEvent, IncomeDetailsState> {
  IncomeDetailsBloc({
    required GetIncomeByIdUseCase getIncomeById,
    required DeleteIncomeUseCase deleteIncome,
  })  : _getIncomeById = getIncomeById,
        _deleteIncome = deleteIncome,
        super(const IncomeDetailsState()) {
    on<IncomeDetailsStarted>(_onStarted);
    on<IncomeDetailsDeleted>(_onDeleted);
  }

  final GetIncomeByIdUseCase _getIncomeById;
  final DeleteIncomeUseCase _deleteIncome;

  Future<void> _onStarted(
    IncomeDetailsStarted event,
    Emitter<IncomeDetailsState> emit,
  ) async {
    emit(state.copyWith(status: IncomeDetailsStatus.loading));
    final result = await _getIncomeById(event.id);
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: IncomeDetailsStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (income) => emit(
        state.copyWith(status: IncomeDetailsStatus.success, income: income),
      ),
    );
  }

  Future<void> _onDeleted(
    IncomeDetailsDeleted event,
    Emitter<IncomeDetailsState> emit,
  ) async {
    emit(state.copyWith(status: IncomeDetailsStatus.deleting));
    final result = await _deleteIncome(event.id);
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: IncomeDetailsStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (_) =>
          emit(state.copyWith(status: IncomeDetailsStatus.deleted)),
    );
  }
}
