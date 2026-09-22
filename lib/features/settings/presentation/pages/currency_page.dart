import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../injection/injection.dart';
import '../bloc/settings_bloc.dart';

class CurrencyOption {
  const CurrencyOption(this.code, this.name);
  final String code;
  final String name;
}

@RoutePage()
class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  static const List<CurrencyOption> presets = [
    CurrencyOption('INR', 'Indian Rupee'),
    CurrencyOption('USD', 'US Dollar'),
    CurrencyOption('EUR', 'Euro'),
    CurrencyOption('GBP', 'British Pound'),
    CurrencyOption('AED', 'UAE Dirham'),
    CurrencyOption('JPY', 'Japanese Yen'),
    CurrencyOption('AUD', 'Australian Dollar'),
    CurrencyOption('CAD', 'Canadian Dollar'),
    CurrencyOption('SGD', 'Singapore Dollar'),
  ];

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(const SettingsStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Currency')),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state.status == SettingsStatus.loading ||
                state.status == SettingsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            final selected = state.currencyCode.trim().toUpperCase();
            final presetCodes =
                CurrencyPage.presets.map((e) => e.code).toSet();
            final isCustom =
                selected.isNotEmpty && !presetCodes.contains(selected);

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: CurrencyPage.presets.length + 3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Choose how amounts are displayed across MoneyTrax.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                final optionIndex = index - 1;
                if (optionIndex < CurrencyPage.presets.length) {
                  final option = CurrencyPage.presets[optionIndex];
                  final isSelected = selected == option.code;
                  String sample;
                  try {
                    sample = CurrencyFormatter.format(
                      1250.5,
                      currencyCode: option.code,
                    );
                  } catch (_) {
                    sample = option.code;
                  }
                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text('${option.code} · ${option.name}'),
                    subtitle: Text('Example: $sample'),
                    selected: isSelected,
                    onTap: () => context
                        .read<SettingsBloc>()
                        .add(SettingsCurrencyChanged(option.code)),
                  );
                }

                if (optionIndex == CurrencyPage.presets.length) {
                  return const Divider(height: 32);
                }

                if (optionIndex == CurrencyPage.presets.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Custom currency code',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                maxLength: 3,
                                decoration: InputDecoration(
                                  labelText: 'ISO code',
                                  hintText:
                                      isCustom ? selected : 'e.g. CHF',
                                  counterText: '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 100,
                              child: FilledButton(
                                onPressed: () {
                                  final code = _customController.text
                                      .trim()
                                      .toUpperCase();
                                  if (code.length < 3) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Enter a 3-letter currency code.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  context
                                      .read<SettingsBloc>()
                                      .add(SettingsCurrencyChanged(code));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Currency set to $code'),
                                    ),
                                  );
                                },
                                child: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                if (!isCustom) return const SizedBox.shrink();
                return ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text('Using custom code: $selected'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
