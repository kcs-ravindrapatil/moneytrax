import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../injection/injection.dart';
import '../bloc/income_form_bloc.dart';

@RoutePage()
class AddIncomePage extends StatelessWidget {
  const AddIncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<IncomeFormBloc>(param1: null)..add(const IncomeFormStarted()),
      child: const _IncomeFormView(title: 'Add Income'),
    );
  }
}

@RoutePage()
class EditIncomePage extends StatelessWidget {
  const EditIncomePage({super.key, required this.incomeId});

  final String incomeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IncomeFormBloc>(param1: incomeId)
        ..add(const IncomeFormStarted()),
      child: const _IncomeFormView(title: 'Edit Income'),
    );
  }
}

class _IncomeFormView extends StatefulWidget {
  const _IncomeFormView({required this.title});

  final String title;

  @override
  State<_IncomeFormView> createState() => _IncomeFormViewState();
}

class _IncomeFormViewState extends State<_IncomeFormView> {
  late final TextEditingController _amountController;
  late final TextEditingController _sourceController;
  late final TextEditingController _noteController;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _sourceController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _hydrateFromState(IncomeFormState state) {
    if (_hydrated) return;
    if (state.status == IncomeFormStatus.loading ||
        state.status == IncomeFormStatus.initial) {
      return;
    }
    _amountController.text = state.amount;
    _sourceController.text = state.source;
    _noteController.text = state.note;
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncomeFormBloc, IncomeFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        _hydrateFromState(state);
        if (state.status == IncomeFormStatus.success) {
          getIt<DataRefreshBus>().notifyChanged();
          context.router.maybePop(true);
        } else if (state.status == IncomeFormStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state.status == IncomeFormStatus.loading) {
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
                onChanged: (v) =>
                    context.read<IncomeFormBloc>().add(IncomeAmountChanged(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(labelText: 'Source'),
                onChanged: (v) =>
                    context.read<IncomeFormBloc>().add(IncomeSourceChanged(v)),
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
                        .read<IncomeFormBloc>()
                        .add(IncomeDateChanged(picked));
                  }
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                maxLines: 3,
                onChanged: (v) =>
                    context.read<IncomeFormBloc>().add(IncomeNoteChanged(v)),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed:
                    state.isValid && state.status != IncomeFormStatus.submitting
                        ? () => context
                            .read<IncomeFormBloc>()
                            .add(const IncomeFormSubmitted())
                        : null,
                child: state.status == IncomeFormStatus.submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Income'),
              ),
            ],
          ),
        );
      },
    );
  }
}
