part of 'expense_form_bloc.dart';

abstract class ExpenseFormEvent extends Equatable {
  const ExpenseFormEvent();
  @override
  List<Object?> get props => [];
}

class ExpenseFormStarted extends ExpenseFormEvent {
  const ExpenseFormStarted();
}

class ExpenseAmountChanged extends ExpenseFormEvent {
  const ExpenseAmountChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ExpenseCategoryChanged extends ExpenseFormEvent {
  const ExpenseCategoryChanged(this.categoryId);
  final String categoryId;
  @override
  List<Object?> get props => [categoryId];
}

class ExpenseDateChanged extends ExpenseFormEvent {
  const ExpenseDateChanged(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

class ExpensePaymentMethodChanged extends ExpenseFormEvent {
  const ExpensePaymentMethodChanged(this.method);
  final String method;
  @override
  List<Object?> get props => [method];
}

class ExpenseNoteChanged extends ExpenseFormEvent {
  const ExpenseNoteChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ExpenseFormSubmitted extends ExpenseFormEvent {
  const ExpenseFormSubmitted();
}
