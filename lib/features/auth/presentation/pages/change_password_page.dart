import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/validators/app_validators.dart';
import '../../../../injection/injection.dart';
import '../bloc/change_password_bloc.dart';

@RoutePage()
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordBloc>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  late final TextEditingController _currentController;
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _currentController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Password')),
      body: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state.status == ChangePasswordStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully.')),
            );
            context.router.maybePop();
          } else if (state.status == ChangePasswordStatus.failure &&
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
              TextFormField(
                controller: _currentController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  errorText: state.currentPassword.isEmpty
                      ? null
                      : AppValidators.password(state.currentPassword),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onChanged: (v) => context
                    .read<ChangePasswordBloc>()
                    .add(ChangePasswordCurrentChanged(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  errorText: state.newPassword.isEmpty
                      ? null
                      : AppValidators.password(state.newPassword),
                ),
                onChanged: (v) => context
                    .read<ChangePasswordBloc>()
                    .add(ChangePasswordNewChanged(v)),
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
                          state.newPassword,
                        ),
                ),
                onChanged: (v) => context
                    .read<ChangePasswordBloc>()
                    .add(ChangePasswordConfirmChanged(v)),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: state.status == ChangePasswordStatus.submitting
                    ? null
                    : () => context
                        .read<ChangePasswordBloc>()
                        .add(const ChangePasswordSubmitted()),
                child: state.status == ChangePasswordStatus.submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Password'),
              ),
            ],
          );
        },
      ),
    );
  }
}
