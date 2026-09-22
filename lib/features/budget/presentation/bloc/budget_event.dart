part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();
  @override
  List<Object?> get props => [];
}

class BudgetStarted extends BudgetEvent {
  const BudgetStarted();
}

class BudgetPeriodChanged extends BudgetEvent {
  const BudgetPeriodChanged({required this.month, required this.year});
  final int month;
  final int year;
  @override
  List<Object?> get props => [month, year];
}

class BudgetUpserted extends BudgetEvent {
  const BudgetUpserted({required this.amount, this.categoryId});
  final double amount;
  final String? categoryId;
  @override
  List<Object?> get props => [amount, categoryId];
}

class BudgetDeleted extends BudgetEvent {
  const BudgetDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
