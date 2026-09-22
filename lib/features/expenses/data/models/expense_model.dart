import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  const ExpenseModel({
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

  @JsonKey(name: 'category_id')
  final String categoryId;

  final String date;

  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  final String? note;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @JsonKey(name: 'category_name', includeFromJson: false, includeToJson: false)
  final String? categoryName;

  @JsonKey(name: 'category_icon', includeFromJson: false, includeToJson: false)
  final String? categoryIcon;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String,
      date: map['date'] as String,
      paymentMethod: map['payment_method'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'category_id': categoryId,
        'date': date,
        'payment_method': paymentMethod,
        'note': note,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  Expense toEntity() => Expense(
        id: id,
        amount: amount,
        categoryId: categoryId,
        date: DateTime.parse(date.length > 10 ? date : '${date}T00:00:00'),
        paymentMethod: paymentMethod,
        note: note,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
        categoryName: categoryName,
        categoryIcon: categoryIcon,
      );

  factory ExpenseModel.fromEntity(Expense entity) => ExpenseModel(
        id: entity.id,
        amount: entity.amount,
        categoryId: entity.categoryId,
        date: entity.date.toIso8601String().split('T').first,
        paymentMethod: entity.paymentMethod,
        note: entity.note,
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt.toIso8601String(),
        categoryName: entity.categoryName,
        categoryIcon: entity.categoryIcon,
      );
}
