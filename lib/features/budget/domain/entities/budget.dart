import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.month,
    required this.year,
    required this.amount,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.spent = 0,
  });

  final String id;
  final int month;
  final int year;
  final double amount;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? categoryName;
  final double spent;

  double get remaining => amount - spent;
  bool get isOverBudget => spent > amount;
  double get usedRatio => amount <= 0 ? 0 : (spent / amount).clamp(0, 2);

  bool get isMonthlyTotal => categoryId == null;

  @override
  List<Object?> get props => [
        id,
        month,
        year,
        amount,
        categoryId,
        createdAt,
        updatedAt,
        categoryName,
        spent,
      ];
}
