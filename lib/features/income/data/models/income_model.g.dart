// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomeModel _$IncomeModelFromJson(Map<String, dynamic> json) => IncomeModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      source: json['source'] as String,
      date: json['date'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$IncomeModelToJson(IncomeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'source': instance.source,
      'date': instance.date,
      'note': instance.note,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
