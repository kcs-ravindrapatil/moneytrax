part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class CategoryStarted extends CategoryEvent {
  const CategoryStarted();
}

class CategorySearchChanged extends CategoryEvent {
  const CategorySearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class CategoryAdded extends CategoryEvent {
  const CategoryAdded({required this.name, this.icon = 'more_horiz'});
  final String name;
  final String icon;
  @override
  List<Object?> get props => [name, icon];
}

class CategoryUpdated extends CategoryEvent {
  const CategoryUpdated({
    required this.id,
    required this.name,
    required this.icon,
  });
  final String id;
  final String name;
  final String icon;
  @override
  List<Object?> get props => [id, name, icon];
}

class CategoryDeleted extends CategoryEvent {
  const CategoryDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
