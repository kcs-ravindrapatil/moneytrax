import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_router.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../injection/injection.dart';
import '../../../../integrations/consent/consent_integration.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../bloc/profile_bloc.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.isEditing = false});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProfileBloc>()..add(ProfileStarted(isEditing: isEditing)),
      child: _ProfileFormView(isEditing: isEditing),
    );
  }
}

@RoutePage()
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage(isEditing: true);
  }
}

class _ProfileFormView extends StatefulWidget {
  const _ProfileFormView({required this.isEditing});

  final bool isEditing;

  @override
  State<_ProfileFormView> createState() => _ProfileFormViewState();
}

class _ProfileFormViewState extends State<_ProfileFormView> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _hydrated = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _hydrateFromState(ProfileState state) {
    if (_hydrated) return;
    if (widget.isEditing) {
      if (state.status == ProfileStatus.loading ||
          state.status == ProfileStatus.initial) {
        return;
      }
      _fullNameController.text = state.fullName;
      _emailController.text = state.email;
      _mobileController.text = state.mobileNumber;
      _hydrated = true;
      return;
    }
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          previous.existingId != current.existingId,
      listener: (context, state) async {
        _hydrateFromState(state);

        if (state.status == ProfileStatus.readyForConsent &&
            !widget.isEditing) {
          context.read<ProfileBloc>().add(const ProfileConsentStarted());
          final consent = await getIt<ConsentIntegration>().createConsent(
            context: context,
            fullName: state.fullName,
            email: state.email,
            mobileNumber: state.mobileNumber,
          );
          if (!context.mounted) return;
          if (consent.isSuccess) {
            context
                .read<ProfileBloc>()
                .add(const ProfileConsentSucceeded());
          } else {
            context.read<ProfileBloc>().add(
                  ProfileConsentFailed(
                    consent.failureOrNull?.message ??
                        'Consent is required to continue.',
                  ),
                );
          }
          return;
        }

        if (state.status == ProfileStatus.success) {
          if (widget.isEditing) {
            context.router.maybePop(true);
          } else {
            await getIt<PreferencesDataSource>().setSessionActive(true);
            if (!context.mounted) return;
            context.router.replace(const MainShellRoute());
          }
        } else if (state.status == ProfileStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ProfileStatus.loading ||
            state.status == ProfileStatus.consenting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    state.status == ProfileStatus.consenting
                        ? 'Processing consent…'
                        : 'Loading…',
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isEditing ? 'Edit Profile' : 'Create Your Profile',
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.isEditing
                    ? 'Update your MoneyTrax profile details.'
                    : 'Tell us a little about you to personalize MoneyTrax.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  errorText: state.fullName.isEmpty
                      ? null
                      : AppValidators.fullName(state.fullName),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (v) => context
                    .read<ProfileBloc>()
                    .add(ProfileFullNameChanged(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: state.email.isEmpty
                      ? null
                      : AppValidators.email(state.email),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) =>
                    context.read<ProfileBloc>().add(ProfileEmailChanged(v)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  errorText: state.mobileNumber.isEmpty
                      ? null
                      : AppValidators.mobileNumber(state.mobileNumber),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (v) =>
                    context.read<ProfileBloc>().add(ProfileMobileChanged(v)),
              ),
              if (!widget.isEditing) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: state.password.isEmpty
                        ? null
                        : AppValidators.password(state.password),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  onChanged: (v) => context
                      .read<ProfileBloc>()
                      .add(ProfilePasswordChanged(v)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    errorText: state.confirmPassword.isEmpty
                        ? null
                        : AppValidators.confirmPassword(
                            state.confirmPassword,
                            state.password,
                          ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                    ),
                  ),
                  onChanged: (v) => context
                      .read<ProfileBloc>()
                      .add(ProfileConfirmPasswordChanged(v)),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: state.isValid &&
                        state.status != ProfileStatus.submitting
                    ? () => context
                        .read<ProfileBloc>()
                        .add(const ProfileSubmitted())
                    : null,
                child: state.status == ProfileStatus.submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? 'Save' : 'Continue'),
              ),
              if (state.status == ProfileStatus.failure &&
                  state.existingId != null &&
                  !widget.isEditing) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context
                      .read<ProfileBloc>()
                      .add(const ProfileRetryConsent()),
                  child: const Text('Retry consent'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
