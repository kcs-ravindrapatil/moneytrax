import '../../../../core/result/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);
  final CategoryRepository _repository;
  Future<Result<List<Category>>> call() => _repository.getCategories();
}

class AddCategoryUseCase {
  AddCategoryUseCase(this._repository);
  final CategoryRepository _repository;
  Future<Result<Category>> call({required String name, required String icon}) =>
      _repository.addCategory(name: name, icon: icon);
}

class DeleteCategoryUseCase {
  DeleteCategoryUseCase(this._repository);
  final CategoryRepository _repository;
  Future<Result<void>> call(String id) => _repository.deleteCategory(id);
}

class UpdateCategoryUseCase {
  UpdateCategoryUseCase(this._repository);
  final CategoryRepository _repository;
  Future<Result<Category>> call(Category category) =>
      _repository.updateCategory(category);
}
