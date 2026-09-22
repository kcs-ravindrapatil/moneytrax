import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/category_usecases.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required GetCategoriesUseCase getCategories,
    required AddCategoryUseCase addCategory,
    required UpdateCategoryUseCase updateCategory,
    required DeleteCategoryUseCase deleteCategory,
  })  : _getCategories = getCategories,
        _addCategory = addCategory,
        _updateCategory = updateCategory,
        _deleteCategory = deleteCategory,
        super(const CategoryState()) {
    on<CategoryStarted>(_onStarted);
    on<CategorySearchChanged>(_onSearchChanged);
    on<CategoryAdded>(_onAdded);
    on<CategoryUpdated>(_onUpdated);
    on<CategoryDeleted>(_onDeleted);
  }

  final GetCategoriesUseCase _getCategories;
  final AddCategoryUseCase _addCategory;
  final UpdateCategoryUseCase _updateCategory;
  final DeleteCategoryUseCase _deleteCategory;

  Future<void> _onStarted(
    CategoryStarted event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await _getCategories();
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (list) => emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: list,
          errorMessage: null,
        ),
      ),
    );
  }

  void _onSearchChanged(
    CategorySearchChanged event,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onAdded(
    CategoryAdded event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await _addCategory(name: event.name, icon: event.icon);
    result.fold(
      onFailure: (f) => emit(state.copyWith(errorMessage: f.message)),
      onSuccess: (_) => add(const CategoryStarted()),
    );
  }

  Future<void> _onUpdated(
    CategoryUpdated event,
    Emitter<CategoryState> emit,
  ) async {
    final existing = state.categories.where((c) => c.id == event.id);
    if (existing.isEmpty) {
      emit(state.copyWith(errorMessage: 'Category not found.'));
      return;
    }
    final current = existing.first;
    final updated = Category(
      id: current.id,
      name: event.name.trim(),
      icon: event.icon,
      isDefault: current.isDefault,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    final result = await _updateCategory(updated);
    result.fold(
      onFailure: (f) => emit(state.copyWith(errorMessage: f.message)),
      onSuccess: (_) => add(const CategoryStarted()),
    );
  }

  Future<void> _onDeleted(
    CategoryDeleted event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await _deleteCategory(event.id);
    result.fold(
      onFailure: (f) => emit(state.copyWith(errorMessage: f.message)),
      onSuccess: (_) => add(const CategoryStarted()),
    );
  }
}
