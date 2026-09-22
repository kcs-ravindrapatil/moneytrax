import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.categoryIcon,
  });

  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String paymentMethod;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? categoryName;
  final String? categoryIcon;

  @override
  List<Object?> get props => [
        id,
        amount,
        categoryId,
        date,
        paymentMethod,
        note,
        createdAt,
        updatedAt,
        categoryName,
        categoryIcon,
      ];
}
