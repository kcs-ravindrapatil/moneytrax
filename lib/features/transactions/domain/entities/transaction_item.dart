import 'package:equatable/equatable.dart';

enum TransactionType { expense, income }

class TransactionItem extends Equatable {
  const TransactionItem({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.title,
    this.subtitle,
    this.categoryId,
    this.icon,
    this.paymentMethod,
    this.note,
  });

  final String id;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String title;
  final String? subtitle;
  final String? categoryId;
  final String? icon;
  final String? paymentMethod;
  final String? note;

  bool get isExpense => type == TransactionType.expense;

  @override
  List<Object?> get props => [
        id,
        amount,
        date,
        type,
        title,
        subtitle,
        categoryId,
        icon,
        paymentMethod,
        note,
      ];
}
