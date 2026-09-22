part of 'expense_details_bloc.dart';

enum ExpenseDetailsStatus {
  initial,
  loading,
  success,
  deleting,
  deleted,
  failure,
}

class ExpenseDetailsState extends Equatable {
  const ExpenseDetailsState({
    this.status = ExpenseDetailsStatus.initial,
    this.expense,
    this.errorMessage,
  });

  final ExpenseDetailsStatus status;
  final Expense? expense;
  final String? errorMessage;

  ExpenseDetailsState copyWith({
    ExpenseDetailsStatus? status,
    Expense? expense,
    String? errorMessage,
  }) {
    return ExpenseDetailsState(
      status: status ?? this.status,
      expense: expense ?? this.expense,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, expense, errorMessage];
}
