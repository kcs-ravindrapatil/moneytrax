import '../../../../core/result/result.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Result<List<Category>>> getCategories();
  Future<Result<Category>> getCategoryById(String id);
  Future<Result<Category>> addCategory({
    required String name,
    required String icon,
  });
  Future<Result<Category>> updateCategory(Category category);
  Future<Result<void>> deleteCategory(String id);
}
