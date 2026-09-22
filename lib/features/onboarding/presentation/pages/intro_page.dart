import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../injection/injection.dart';
import '../bloc/onboarding_bloc.dart';

@RoutePage()
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  static const _slides = [
    (
      Icons.payments_rounded,
      'Track every rupee',
      'Log daily expenses in seconds with categories and payment methods.',
      Color(0xFF0F766E),
    ),
    (
      Icons.insights_rounded,
      'Understand your spending',
      'See weekly and monthly trends with clear charts and summaries.',
      Color(0xFF0369A1),
    ),
    (
      Icons.savings_rounded,
      'Stay on budget',
      'Set monthly and category budgets, then stay ahead of overspending.',
      Color(0xFF047857),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingBloc>(),
      child: const _IntroView(),
    );
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (p, c) => p.pageIndex != c.pageIndex || c.completed,
      listener: (context, state) {
        if (state.completed) {
          context.router.replace(const WelcomeRoute());
        }
      },
      builder: (context, state) {
        final slide = IntroPage._slides[state.pageIndex];
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context
                          .read<OnboardingBloc>()
                          .add(const OnboardingSkipPressed()),
                      child: const Text('Skip'),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: slide.$4.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(slide.$1, size: 80, color: slide.$4),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    slide.$2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.$3,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(IntroPage._slides.length, (i) {
                      final active = i == state.pageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingNextPressed()),
                    child: Text(
                      state.pageIndex == IntroPage._slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                  if (state.pageIndex > 0) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.read<OnboardingBloc>().add(
                            OnboardingPageChanged(state.pageIndex - 1),
                          ),
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
