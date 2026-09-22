part of 'expense_details_bloc.dart';

abstract class ExpenseDetailsEvent extends Equatable {
  const ExpenseDetailsEvent();
  @override
  List<Object?> get props => [];
}

class ExpenseDetailsStarted extends ExpenseDetailsEvent {
  const ExpenseDetailsStarted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ExpenseDetailsDeleted extends ExpenseDetailsEvent {
  const ExpenseDetailsDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
