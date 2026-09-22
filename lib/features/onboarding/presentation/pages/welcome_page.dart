import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../injection/injection.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';

@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: FutureBuilder(
            future: getIt<GetProfileUseCase>()(),
            builder: (context, snapshot) {
              final hasProfile =
                  snapshot.hasData && snapshot.data?.dataOrNull != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.tertiary],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasProfile
                        ? 'Welcome back.'
                        : 'Your simple daily\nexpense tracker.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasProfile
                        ? 'Log in with your email or mobile number and password.'
                        : AppConstants.appSlogan,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (hasProfile) {
                        context.router.push(const LoginRoute());
                      } else {
                        context.router.push(ProfileRoute());
                      }
                    },
                    child: Text(hasProfile ? 'Login' : 'Get Started'),
                  ),
                  if (!hasProfile) ...[
                    const SizedBox(height: 12),
                    Text(
                      'No unnecessary permissions. Your expense data stays on this device.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
