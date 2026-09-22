import 'package:flutter/material.dart';

import '../utils/formatters.dart';

IconData categoryIconData(String? icon) {
  switch (icon) {
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'shopping_cart':
      return Icons.shopping_cart_rounded;
    case 'shopping_bag':
      return Icons.shopping_bag_rounded;
    case 'local_gas_station':
      return Icons.local_gas_station_rounded;
    case 'flight':
      return Icons.flight_rounded;
    case 'home':
      return Icons.home_rounded;
    case 'bolt':
      return Icons.bolt_rounded;
    case 'movie':
      return Icons.movie_rounded;
    case 'favorite':
      return Icons.favorite_rounded;
    case 'school':
      return Icons.school_rounded;
    case 'subscriptions':
      return Icons.subscriptions_rounded;
    case 'security':
      return Icons.security_rounded;
    case 'payments':
      return Icons.payments_rounded;
    case 'directions_car':
      return Icons.directions_car_rounded;
    case 'fitness_center':
      return Icons.fitness_center_rounded;
    case 'pets':
      return Icons.pets_rounded;
    case 'work':
      return Icons.work_rounded;
    case 'card_giftcard':
      return Icons.card_giftcard_rounded;
    case 'more_horiz':
    default:
      return Icons.category_rounded;
  }
}

/// Icon keys available for category pickers.
const List<String> kCategoryIconKeys = [
  'restaurant',
  'shopping_cart',
  'shopping_bag',
  'local_gas_station',
  'directions_car',
  'flight',
  'home',
  'bolt',
  'movie',
  'favorite',
  'fitness_center',
  'school',
  'subscriptions',
  'security',
  'payments',
  'work',
  'pets',
  'card_giftcard',
  'more_horiz',
];

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                onChanged?.call('');
              },
            );
          },
        ),
      ),
    );
  }
}


class MoneyCard extends StatelessWidget {
  const MoneyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: colors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Loading…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.isExpense = false,
    this.isIncome = false,
    this.style,
  });

  final double amount;
  final String currencyCode;
  final bool isExpense;
  final bool isIncome;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Color? color;
    if (isExpense) color = colors.error;
    if (isIncome) color = colors.tertiary;

    return Text(
      CurrencyFormatter.format(
        amount,
        currencyCode: currencyCode,
        withSign: isExpense || isIncome,
        negative: isExpense,
      ),
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// From / To date filter row used on Transactions and Reports.
class DateRangeFilterBar extends StatelessWidget {
  const DateRangeFilterBar({
    super.key,
    required this.from,
    required this.to,
    required this.onChanged,
    this.onCleared,
    this.allowClear = true,
  });

  final DateTime? from;
  final DateTime? to;
  final void Function(DateTime from, DateTime to) onChanged;
  final VoidCallback? onCleared;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    final hasRange = from != null && to != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickRange(context),
              icon: const Icon(Icons.date_range, size: 18),
              label: Text(
                hasRange
                    ? '${DateFormatter.dayMonthYear(from!)} → ${DateFormatter.dayMonthYear(to!)}'
                    : 'From – To date',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (allowClear && hasRange && onCleared != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Clear dates',
              onPressed: onCleared,
              icon: const Icon(Icons.clear),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final initialStart = from ?? DateTime(now.year, now.month, 1);
    final initialEnd = to ?? DateTime(now.year, now.month, now.day);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      helpText: 'Select date range',
      saveText: 'Apply',
    );
    if (range == null) return;
    onChanged(
      DateTime(range.start.year, range.start.month, range.start.day),
      DateTime(range.end.year, range.end.month, range.end.day),
    );
  }
}

