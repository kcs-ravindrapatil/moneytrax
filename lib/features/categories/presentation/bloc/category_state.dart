part of 'category_bloc.dart';

enum CategoryStatus { initial, loading, success, failure }

class CategoryState extends Equatable {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  final CategoryStatus status;
  final List<Category> categories;
  final String searchQuery;
  final String? errorMessage;

  List<Category> get filteredCategories {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return categories;
    return categories
        .where((c) => c.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, searchQuery, errorMessage];
}
