part of 'income_form_bloc.dart';

enum IncomeFormStatus {
  initial,
  loading,
  editing,
  submitting,
  success,
  failure
}

class IncomeFormState extends Equatable {
  const IncomeFormState({
    this.status = IncomeFormStatus.initial,
    this.amount = '',
    this.source = '',
    this.date,
    this.note = '',
    this.isValid = false,
    this.errorMessage,
    this.existingCreatedAt,
  });

  final IncomeFormStatus status;
  final String amount;
  final String source;
  final DateTime? date;
  final String note;
  final bool isValid;
  final String? errorMessage;
  final DateTime? existingCreatedAt;

  IncomeFormState copyWith({
    IncomeFormStatus? status,
    String? amount,
    String? source,
    DateTime? date,
    String? note,
    bool? isValid,
    String? errorMessage,
    DateTime? existingCreatedAt,
  }) {
    return IncomeFormState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      date: date ?? this.date,
      note: note ?? this.note,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
      existingCreatedAt: existingCreatedAt ?? this.existingCreatedAt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        amount,
        source,
        date,
        note,
        isValid,
        errorMessage,
        existingCreatedAt,
      ];
}
