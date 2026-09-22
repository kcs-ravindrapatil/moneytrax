import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection/injection.dart';
import '../bloc/settings_bloc.dart';

@RoutePage()
class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(const SettingsStarted()),
      child: const _PaymentMethodsView(),
    );
  }
}

class _PaymentMethodsView extends StatelessWidget {
  const _PaymentMethodsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final bloc = context.read<SettingsBloc>();
              final name = await showDialog<String>(
                context: context,
                builder: (ctx) => const _AddPaymentMethodDialog(),
              );
              if (name != null && name.isNotEmpty) {
                bloc.add(
                  SettingsPaymentMethodsUpdated([
                    ...bloc.state.paymentMethods,
                    name,
                  ]),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.paymentMethods.length,
            itemBuilder: (context, index) {
              final method = state.paymentMethods[index];
              return ListTile(
                title: Text(method),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    final next = [...state.paymentMethods]..removeAt(index);
                    if (next.isEmpty) return;
                    context
                        .read<SettingsBloc>()
                        .add(SettingsPaymentMethodsUpdated(next));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddPaymentMethodDialog extends StatefulWidget {
  const _AddPaymentMethodDialog();

  @override
  State<_AddPaymentMethodDialog> createState() =>
      _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<_AddPaymentMethodDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add payment method'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Name'),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }
}
