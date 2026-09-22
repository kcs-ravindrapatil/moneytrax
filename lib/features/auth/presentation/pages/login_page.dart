import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../injection/injection.dart';
import '../bloc/auth_bloc.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            context.router.replaceAll([const MainShellRoute()]);
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
                'Sign in with your email or mobile number and password.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _identifierController,
                decoration: InputDecoration(
                  labelText: 'Email or Mobile',
                  errorText: state.identifier.isEmpty
                      ? null
                      : AppValidators.loginIdentifier(state.identifier),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) =>
                    context.read<AuthBloc>().add(AuthIdentifierChanged(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: state.obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      context.router.push(const ForgotPasswordRoute()),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: state.status == AuthStatus.submitting
                    ? null
                    : () => context
                        .read<AuthBloc>()
                        .add(const AuthLoginSubmitted()),
                child: state.status == AuthStatus.submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ],
          );
        },
      ),
    );
  }
}
