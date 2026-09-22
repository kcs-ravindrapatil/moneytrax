part of 'income_form_bloc.dart';

abstract class IncomeFormEvent extends Equatable {
  const IncomeFormEvent();
  @override
  List<Object?> get props => [];
}

class IncomeFormStarted extends IncomeFormEvent {
  const IncomeFormStarted();
}

class IncomeAmountChanged extends IncomeFormEvent {
  const IncomeAmountChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class IncomeSourceChanged extends IncomeFormEvent {
  const IncomeSourceChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class IncomeDateChanged extends IncomeFormEvent {
  const IncomeDateChanged(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

class IncomeNoteChanged extends IncomeFormEvent {
  const IncomeNoteChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class IncomeFormSubmitted extends IncomeFormEvent {
  const IncomeFormSubmitted();
}
