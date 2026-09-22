part of 'income_details_bloc.dart';

abstract class IncomeDetailsEvent extends Equatable {
  const IncomeDetailsEvent();
  @override
  List<Object?> get props => [];
}

class IncomeDetailsStarted extends IncomeDetailsEvent {
  const IncomeDetailsStarted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class IncomeDetailsDeleted extends IncomeDetailsEvent {
  const IncomeDetailsDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
