import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';

@RoutePage()
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryBloc>()..add(const CategoryStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _openEditor(context),
              ),
            ),
          ],
        ),
        body: BlocConsumer<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            if (state.status == CategoryStatus.loading ||
                state.status == CategoryStatus.initial) {
              return const LoadingView();
            }
            if (state.status == CategoryStatus.failure) {
              return ErrorStateView(
                message: state.errorMessage ?? 'Failed to load',
                onRetry: () =>
                    context.read<CategoryBloc>().add(const CategoryStarted()),
              );
            }
            final items = state.filteredCategories;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: AppSearchField(
                    controller: _searchController,
                    hintText: 'Search categories',
                    onChanged: (q) => context
                        .read<CategoryBloc>()
                        .add(CategorySearchChanged(q)),
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const EmptyStateView(
                          title: 'No categories',
                          message: 'Try another search or add a category.',
                          icon: Icons.category_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final c = items[index];
                            return MoneyCard(
                              onTap: () => _openEditor(context, category: c),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(categoryIconData(c.icon)),
                                ),
                                title: Text(c.name),
                                trailing: c.isDefault
                                    ? const Icon(Icons.chevron_right)
                                    : IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => context
                                            .read<CategoryBloc>()
                                            .add(CategoryDeleted(c.id)),
                                      ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    Category? category,
  }) async {
    final bloc = context.read<CategoryBloc>();
    final result = await showDialog<_CategoryEditResult>(
      context: context,
      builder: (ctx) => _CategoryEditorDialog(category: category),
    );
    if (result == null) return;
    if (category == null) {
      bloc.add(CategoryAdded(name: result.name, icon: result.icon));
    } else {
      bloc.add(
        CategoryUpdated(
          id: category.id,
          name: result.name,
          icon: result.icon,
        ),
      );
    }
  }
}

class _CategoryEditResult {
  const _CategoryEditResult({required this.name, required this.icon});
  final String name;
  final String icon;
}

class _CategoryEditorDialog extends StatefulWidget {
  const _CategoryEditorDialog({this.category});

  final Category? category;

  @override
  State<_CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<_CategoryEditorDialog> {
  late final TextEditingController _nameController;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon ?? 'more_horiz';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Category' : 'Add Category'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Icon',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: kCategoryIconKeys.length,
                itemBuilder: (context, index) {
                  final key = kCategoryIconKeys[index];
                  final selected = key == _selectedIcon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = key),
                    borderRadius: BorderRadius.circular(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(categoryIconData(key)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              _CategoryEditResult(name: name, icon: _selectedIcon),
            );
          },
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
