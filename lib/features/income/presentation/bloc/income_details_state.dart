part of 'income_details_bloc.dart';

enum IncomeDetailsStatus {
  initial,
  loading,
  success,
  deleting,
  deleted,
  failure,
}

class IncomeDetailsState extends Equatable {
  const IncomeDetailsState({
    this.status = IncomeDetailsStatus.initial,
    this.income,
    this.errorMessage,
  });

  final IncomeDetailsStatus status;
  final Income? income;
  final String? errorMessage;

  IncomeDetailsState copyWith({
    IncomeDetailsStatus? status,
    Income? income,
    String? errorMessage,
  }) {
    return IncomeDetailsState(
      status: status ?? this.status,
      income: income ?? this.income,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, income, errorMessage];
}
