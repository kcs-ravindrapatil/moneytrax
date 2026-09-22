import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/password_hasher.dart';
import '../../../../core/validators/app_validators.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile_usecases.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required SaveProfileUseCase saveProfile,
    required UpdateProfileUseCase updateProfile,
    required GetProfileUseCase getProfile,
  })  : _saveProfile = saveProfile,
        _updateProfile = updateProfile,
        _getProfile = getProfile,
        super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileFullNameChanged>(_onFullNameChanged);
    on<ProfileEmailChanged>(_onEmailChanged);
    on<ProfileMobileChanged>(_onMobileChanged);
    on<ProfilePasswordChanged>(_onPasswordChanged);
    on<ProfileConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<ProfileSubmitted>(_onSubmitted);
    on<ProfileConsentStarted>(_onConsentStarted);
    on<ProfileConsentSucceeded>(_onConsentSucceeded);
    on<ProfileConsentFailed>(_onConsentFailed);
    on<ProfileRetryConsent>(_onRetryConsent);
  }

  final SaveProfileUseCase _saveProfile;
  final UpdateProfileUseCase _updateProfile;
  final GetProfileUseCase _getProfile;
  final _uuid = const Uuid();

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    if (!event.isEditing) {
      emit(state.copyWith(status: ProfileStatus.editing));
      return;
    }
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _getProfile();
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(status: ProfileStatus.failure, errorMessage: f.message),
      ),
      onSuccess: (profile) {
        if (profile == null) {
          emit(state.copyWith(status: ProfileStatus.editing));
          return;
        }
        emit(
          state.copyWith(
            status: ProfileStatus.editing,
            existingId: profile.id,
            fullName: profile.fullName,
            email: profile.email,
            mobileNumber: profile.mobileNumber,
            createdAt: profile.createdAt,
            existingPasswordHash: profile.passwordHash,
            existingPasswordSalt: profile.passwordSalt,
            isValid: true,
          ),
        );
      },
    );
  }

  void _onFullNameChanged(
    ProfileFullNameChanged event,
    Emitter<ProfileState> emit,
  ) {
    final next = state.copyWith(fullName: event.value);
    emit(next.copyWith(isValid: _validate(next), errorMessage: null));
  }

  void _onEmailChanged(
    ProfileEmailChanged event,
    Emitter<ProfileState> emit,
  ) {
    final next = state.copyWith(email: event.value);
    emit(next.copyWith(isValid: _validate(next), errorMessage: null));
  }

  void _onMobileChanged(
    ProfileMobileChanged event,
    Emitter<ProfileState> emit,
  ) {
    final next = state.copyWith(mobileNumber: event.value);
    emit(next.copyWith(isValid: _validate(next), errorMessage: null));
  }

  void _onPasswordChanged(
    ProfilePasswordChanged event,
    Emitter<ProfileState> emit,
  ) {
    final next = state.copyWith(password: event.value);
    emit(next.copyWith(isValid: _validate(next), errorMessage: null));
  }

  void _onConfirmPasswordChanged(
    ProfileConfirmPasswordChanged event,
    Emitter<ProfileState> emit,
  ) {
    final next = state.copyWith(confirmPassword: event.value);
    emit(next.copyWith(isValid: _validate(next), errorMessage: null));
  }

  bool _validate(ProfileState s) => AppValidators.isProfileValid(
        fullName: s.fullName,
        email: s.email,
        mobileNumber: s.mobileNumber,
        password: s.password,
        confirmPassword: s.confirmPassword,
        requirePassword: !s.isEditing,
      );

  Future<void> _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (!_validate(state)) {
      emit(
        state.copyWith(
          status: ProfileStatus.editing,
          errorMessage: 'Please fix the highlighted fields.',
          isValid: false,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileStatus.submitting));
    final now = DateTime.now();
    final isNewRegistration = state.existingId == null;

    String? hash = state.existingPasswordHash;
    String? salt = state.existingPasswordSalt;
    if (isNewRegistration) {
      salt = PasswordHasher.generateSalt();
      hash = PasswordHasher.hash(state.password, salt);
    }

    final profile = UserProfile(
      id: state.existingId ?? _uuid.v4(),
      fullName: state.fullName.trim(),
      email: state.email.trim(),
      mobileNumber: state.mobileNumber.trim(),
      passwordHash: hash,
      passwordSalt: salt,
      createdAt: state.createdAt ?? now,
      updatedAt: now,
    );

    final result = isNewRegistration
        ? await _saveProfile(profile)
        : await _updateProfile(profile);

    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (_) {
        if (isNewRegistration) {
          emit(
            state.copyWith(
              status: ProfileStatus.readyForConsent,
              existingId: profile.id,
              createdAt: profile.createdAt,
              existingPasswordHash: hash,
              existingPasswordSalt: salt,
              errorMessage: null,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: ProfileStatus.success,
              existingId: profile.id,
            ),
          );
        }
      },
    );
  }

  void _onConsentStarted(
    ProfileConsentStarted event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(status: ProfileStatus.consenting, errorMessage: null));
  }

  void _onConsentSucceeded(
    ProfileConsentSucceeded event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(status: ProfileStatus.success, errorMessage: null));
  }

  void _onConsentFailed(
    ProfileConsentFailed event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  void _onRetryConsent(
    ProfileRetryConsent event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      state.copyWith(
        status: ProfileStatus.readyForConsent,
        errorMessage: null,
      ),
    );
  }
}
