part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionStarted extends TransactionEvent {
  const TransactionStarted();
}

class TransactionRefreshed extends TransactionEvent {
  const TransactionRefreshed();
}

class TransactionSearchChanged extends TransactionEvent {
  const TransactionSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class TransactionTypeFilterChanged extends TransactionEvent {
  const TransactionTypeFilterChanged(this.type);
  final TransactionFilterType type;
  @override
  List<Object?> get props => [type];
}

class TransactionCategoryFilterChanged extends TransactionEvent {
  const TransactionCategoryFilterChanged(this.categoryId);
  final String? categoryId;
  @override
  List<Object?> get props => [categoryId];
}

class TransactionDateRangeChanged extends TransactionEvent {
  const TransactionDateRangeChanged({
    this.from,
    this.to,
    this.clear = false,
  });
  final DateTime? from;
  final DateTime? to;
  final bool clear;
  @override
  List<Object?> get props => [from, to, clear];
}

class TransactionSortChanged extends TransactionEvent {
  const TransactionSortChanged({
    required this.sortBy,
    required this.ascending,
  });
  final TransactionSortBy sortBy;
  final bool ascending;
  @override
  List<Object?> get props => [sortBy, ascending];
}
