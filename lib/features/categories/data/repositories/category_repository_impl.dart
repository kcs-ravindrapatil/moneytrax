import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._local);

  final CategoryLocalDataSource _local;

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final models = await _local.getCategories();
      return Success(models.map((m) => m.toEntity()).toList());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    try {
      final model = await _local.getCategoryById(id);
      if (model == null) {
        return const Error(NotFoundFailure('Category not found.'));
      }
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Category>> addCategory({
    required String name,
    required String icon,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final model = await _local.addCategory(
        CategoryModel(
          id: '',
          name: name.trim(),
          icon: icon,
          isDefault: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    try {
      final model =
          await _local.updateCategory(CategoryModel.fromEntity(category));
      return Success(model.toEntity());
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await _local.deleteCategory(id);
      return const Success(null);
    } on AppDatabaseException catch (e) {
      return Error(DatabaseFailure(e.message));
    } catch (_) {
      return const Error(UnexpectedFailure());
    }
  }
}
