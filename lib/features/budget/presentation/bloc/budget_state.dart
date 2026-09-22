part of 'budget_bloc.dart';

enum BudgetStatus { initial, loading, success, failure }

class BudgetState extends Equatable {
  const BudgetState({
    this.status = BudgetStatus.initial,
    this.budgets = const [],
    this.categories = const [],
    required this.month,
    required this.year,
    this.currencyCode = 'INR',
    this.errorMessage,
  });

  final BudgetStatus status;
  final List<Budget> budgets;
  final List<Category> categories;
  final int month;
  final int year;
  final String currencyCode;
  final String? errorMessage;

  Budget? get monthlyBudget {
    for (final b in budgets) {
      if (b.isMonthlyTotal) return b;
    }
    return null;
  }

  List<Budget> get categoryBudgets =>
      budgets.where((b) => !b.isMonthlyTotal).toList();

  BudgetState copyWith({
    BudgetStatus? status,
    List<Budget>? budgets,
    List<Category>? categories,
    int? month,
    int? year,
    String? currencyCode,
    String? errorMessage,
  }) {
    return BudgetState(
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
      categories: categories ?? this.categories,
      month: month ?? this.month,
      year: year ?? this.year,
      currencyCode: currencyCode ?? this.currencyCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        budgets,
        categories,
        month,
        year,
        currencyCode,
        errorMessage,
      ];
}
