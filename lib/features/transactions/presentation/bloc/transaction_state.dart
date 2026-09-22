part of 'transaction_bloc.dart';

enum TransactionStatus { initial, loading, success, empty, failure }

class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.items = const [],
    this.categories = const [],
    this.search = '',
    this.filterType = TransactionFilterType.all,
    this.categoryId,
    this.from,
    this.to,
    this.sortBy = TransactionSortBy.date,
    this.ascending = false,
    this.currencyCode = 'INR',
    this.errorMessage,
  });

  final TransactionStatus status;
  final List<TransactionItem> items;
  final List<Category> categories;
  final String search;
  final TransactionFilterType filterType;
  final String? categoryId;
  final DateTime? from;
  final DateTime? to;
  final TransactionSortBy sortBy;
  final bool ascending;
  final String currencyCode;
  final String? errorMessage;

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionItem>? items,
    List<Category>? categories,
    String? search,
    TransactionFilterType? filterType,
    String? categoryId,
    bool clearCategoryId = false,
    DateTime? from,
    DateTime? to,
    bool clearDateRange = false,
    TransactionSortBy? sortBy,
    bool? ascending,
    String? currencyCode,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      search: search ?? this.search,
      filterType: filterType ?? this.filterType,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      from: clearDateRange ? null : (from ?? this.from),
      to: clearDateRange ? null : (to ?? this.to),
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      currencyCode: currencyCode ?? this.currencyCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        categories,
        search,
        filterType,
        categoryId,
        from,
        to,
        sortBy,
        ascending,
        currencyCode,
        errorMessage,
      ];
}
