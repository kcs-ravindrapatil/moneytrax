import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class BudgetModel {
  const BudgetModel({
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

  @JsonKey(name: 'category_id')
  final String? categoryId;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? categoryName;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final double spent;

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      month: map['month'] as int,
      year: map['year'] as int,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      categoryName: map['category_name'] as String?,
      spent: (map['spent'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'month': month,
        'year': year,
        'amount': amount,
        'category_id': categoryId,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  Budget toEntity() => Budget(
        id: id,
        month: month,
        year: year,
        amount: amount,
        categoryId: categoryId,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
        categoryName: categoryName,
        spent: spent,
      );

  factory BudgetModel.fromEntity(Budget entity) => BudgetModel(
        id: entity.id,
        month: entity.month,
        year: entity.year,
        amount: entity.amount,
        categoryId: entity.categoryId,
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt.toIso8601String(),
        categoryName: entity.categoryName,
        spent: entity.spent,
      );
}
