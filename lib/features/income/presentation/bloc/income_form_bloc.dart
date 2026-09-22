import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/validators/app_validators.dart';
import '../../domain/entities/income.dart';
import '../../domain/usecases/income_usecases.dart';

part 'income_form_event.dart';
part 'income_form_state.dart';

class IncomeFormBloc extends Bloc<IncomeFormEvent, IncomeFormState> {
  IncomeFormBloc({
    required AddIncomeUseCase addIncome,
    required UpdateIncomeUseCase updateIncome,
    required GetIncomeByIdUseCase getIncomeById,
    String? incomeId,
  })  : _addIncome = addIncome,
        _updateIncome = updateIncome,
        _getIncomeById = getIncomeById,
        _incomeId = incomeId,
        super(const IncomeFormState()) {
    on<IncomeFormStarted>(_onStarted);
    on<IncomeAmountChanged>(_onAmountChanged);
    on<IncomeSourceChanged>(_onSourceChanged);
    on<IncomeDateChanged>(_onDateChanged);
    on<IncomeNoteChanged>(_onNoteChanged);
    on<IncomeFormSubmitted>(_onSubmitted);
  }

  final AddIncomeUseCase _addIncome;
  final UpdateIncomeUseCase _updateIncome;
  final GetIncomeByIdUseCase _getIncomeById;
  final String? _incomeId;
  final _uuid = const Uuid();

  Future<void> _onStarted(
    IncomeFormStarted event,
    Emitter<IncomeFormState> emit,
  ) async {
    if (_incomeId == null) {
      emit(
        state.copyWith(
          status: IncomeFormStatus.editing,
          date: DateTime.now(),
        ),
      );
      return;
    }
    emit(state.copyWith(status: IncomeFormStatus.loading));
    final result = await _getIncomeById(_incomeId);
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: IncomeFormStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (income) => emit(
        state.copyWith(
          status: IncomeFormStatus.editing,
          amount: income.amount.toString(),
          source: income.source,
          date: income.date,
          note: income.note ?? '',
          existingCreatedAt: income.createdAt,
          isValid: true,
        ),
      ),
    );
  }

  void _onAmountChanged(
    IncomeAmountChanged event,
    Emitter<IncomeFormState> emit,
  ) {
    final next = state.copyWith(amount: event.value);
    emit(next.copyWith(isValid: _isValid(next)));
  }

  void _onSourceChanged(
    IncomeSourceChanged event,
    Emitter<IncomeFormState> emit,
  ) {
    final next = state.copyWith(source: event.value);
    emit(next.copyWith(isValid: _isValid(next)));
  }

  void _onDateChanged(
    IncomeDateChanged event,
    Emitter<IncomeFormState> emit,
  ) {
    final next = state.copyWith(date: event.date);
    emit(next.copyWith(isValid: _isValid(next)));
  }

  void _onNoteChanged(
    IncomeNoteChanged event,
    Emitter<IncomeFormState> emit,
  ) {
    emit(state.copyWith(note: event.value));
  }

  bool _isValid(IncomeFormState s) =>
      AppValidators.amount(s.amount) == null &&
      AppValidators.requiredField(s.source, field: 'Source') == null &&
      s.date != null;

  Future<void> _onSubmitted(
    IncomeFormSubmitted event,
    Emitter<IncomeFormState> emit,
  ) async {
    if (!_isValid(state)) {
      emit(state.copyWith(errorMessage: 'Please complete required fields.'));
      return;
    }
    emit(state.copyWith(status: IncomeFormStatus.submitting));
    final now = DateTime.now();
    final income = Income(
      id: _incomeId ?? _uuid.v4(),
      amount: double.parse(state.amount),
      source: state.source.trim(),
      date: state.date!,
      note: state.note.trim().isEmpty ? null : state.note.trim(),
      createdAt: state.existingCreatedAt ?? now,
      updatedAt: now,
    );
    final result = _incomeId == null
        ? await _addIncome(income)
        : await _updateIncome(income);
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: IncomeFormStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (_) => emit(state.copyWith(status: IncomeFormStatus.success)),
    );
  }
}
