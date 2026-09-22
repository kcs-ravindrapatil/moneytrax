import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/income.dart';

part 'income_model.g.dart';

@JsonSerializable()
class IncomeModel {
  const IncomeModel({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final double amount;
  final String source;
  final String date;
  final String? note;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  factory IncomeModel.fromJson(Map<String, dynamic> json) =>
      _$IncomeModelFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeModelToJson(this);

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      source: map['source'] as String,
      date: map['date'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'source': source,
        'date': date,
        'note': note,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  Income toEntity() => Income(
        id: id,
        amount: amount,
        source: source,
        date: DateTime.parse(date.length > 10 ? date : '${date}T00:00:00'),
        note: note,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );

  factory IncomeModel.fromEntity(Income entity) => IncomeModel(
        id: entity.id,
        amount: entity.amount,
        source: entity.source,
        date: entity.date.toIso8601String().split('T').first,
        note: entity.note,
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt.toIso8601String(),
      );
}
