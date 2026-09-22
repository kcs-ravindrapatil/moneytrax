import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../injection/injection.dart';
import '../bloc/auth_bloc.dart';

@RoutePage()
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.resetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password updated. Please log in.'),
              ),
            );
            context.router.replace(const LoginRoute());
          } else if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Verify your registered email and mobile number, then set a new password. '
                'All data stays on this device.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Registered Email',
                  errorText: state.email.isEmpty
                      ? null
                      : AppValidators.email(state.email),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) =>
                    context.read<AuthBloc>().add(AuthEmailChanged(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Registered Mobile',
                  errorText: state.mobileNumber.isEmpty
                      ? null
                      : AppValidators.mobileNumber(state.mobileNumber),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (v) =>
                    context.read<AuthBloc>().add(AuthMobileChanged(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: state.obscurePassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  errorText: state.password.isEmpty
                      ? null
                      : AppValidators.password(state.password),
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthObscureToggled()),
                  ),
                ),
                onChanged: (v) =>
                    context.read<AuthBloc>().add(AuthPasswordChanged(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  errorText: state.confirmPassword.isEmpty
                      ? null
                      : AppValidators.confirmPassword(
                          state.confirmPassword,
                          state.password,
                        ),
                ),
                onChanged: (v) => context
                    .read<AuthBloc>()
                    .add(AuthConfirmPasswordChanged(v)),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: state.status == AuthStatus.submitting
                    ? null
                    : () => context
                        .read<AuthBloc>()
                        .add(const AuthResetSubmitted()),
                child: state.status == AuthStatus.submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reset Password'),
              ),
            ],
          );
        },
      ),
    );
  }
}
