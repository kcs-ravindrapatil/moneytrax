import 'package:equatable/equatable.dart';

class Income extends Equatable {
  const Income({
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
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, amount, source, date, note, createdAt, updatedAt];
}
