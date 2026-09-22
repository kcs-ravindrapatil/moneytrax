import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../bloc/expense_form_bloc.dart';

@RoutePage()
class AddExpensePage extends StatelessWidget {
  const AddExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ExpenseFormBloc>(param1: null)..add(const ExpenseFormStarted()),
      child: const _ExpenseFormView(title: 'Add Expense'),
    );
  }
}

@RoutePage()
class EditExpensePage extends StatelessWidget {
  const EditExpensePage({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExpenseFormBloc>(param1: expenseId)
        ..add(const ExpenseFormStarted()),
      child: const _ExpenseFormView(title: 'Edit Expense'),
    );
  }
}

class _ExpenseFormView extends StatefulWidget {
  const _ExpenseFormView({required this.title});

  final String title;

  @override
  State<_ExpenseFormView> createState() => _ExpenseFormViewState();
}

class _ExpenseFormViewState extends State<_ExpenseFormView> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _hydrateFromState(ExpenseFormState state) {
    if (_hydrated) return;
    if (state.status == ExpenseFormStatus.loading ||
        state.status == ExpenseFormStatus.initial) {
      return;
    }
    _amountController.text = state.amount;
    _noteController.text = state.note;
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseFormBloc, ExpenseFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) async {
        _hydrateFromState(state);
        if (state.status == ExpenseFormStatus.success) {
          getIt<DataRefreshBus>().notifyChanged();
          final prefs = getIt<PreferencesDataSource>();
          if (await prefs.areNotificationsEnabled()) {
            final currency = await prefs.getCurrencyCode();
            final amount = double.tryParse(state.amount) ?? 0;
            String? categoryName;
            for (final c in state.categories) {
              if (c.id == state.categoryId) {
                categoryName = c.name;
                break;
              }
            }
            await getIt<NotificationService>().showExpenseLogged(
              amountLabel: CurrencyFormatter.format(
                amount,
                currencyCode: currency,
              ),
              categoryName: categoryName,
            );
          }
          if (!context.mounted) return;
          context.router.maybePop(true);
        } else if (state.errorMessage != null &&
            state.status == ExpenseFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ExpenseFormStatus.loading) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: const LoadingView(),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => context
                    .read<ExpenseFormBloc>()
                    .add(ExpenseAmountChanged(v)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: state.categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: state.categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    context
                        .read<ExpenseFormBloc>()
                        .add(ExpenseCategoryChanged(v));
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  state.date == null
                      ? 'Select date'
                      : DateFormatter.dayMonthYear(state.date!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && context.mounted) {
                    context
                        .read<ExpenseFormBloc>()
                        .add(ExpenseDateChanged(picked));
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: state.paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: state.paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    context
                        .read<ExpenseFormBloc>()
                        .add(ExpensePaymentMethodChanged(v));
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                maxLines: 3,
                onChanged: (v) =>
                    context.read<ExpenseFormBloc>().add(ExpenseNoteChanged(v)),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: state.isValid &&
                        state.status != ExpenseFormStatus.submitting
                    ? () => context
                        .read<ExpenseFormBloc>()
                        .add(const ExpenseFormSubmitted())
                    : null,
                child: state.status == ExpenseFormStatus.submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Expense'),
              ),
            ],
          ),
        );
      },
    );
  }
}
