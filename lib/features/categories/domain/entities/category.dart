import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String icon;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, icon, isDefault, createdAt, updatedAt];
}
