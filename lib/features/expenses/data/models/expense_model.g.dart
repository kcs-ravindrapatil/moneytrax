// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as String,
      date: json['date'] as String,
      paymentMethod: json['payment_method'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'category_id': instance.categoryId,
      'date': instance.date,
      'payment_method': instance.paymentMethod,
      'note': instance.note,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
