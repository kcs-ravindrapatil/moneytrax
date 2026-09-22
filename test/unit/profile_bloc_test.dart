import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:conveygrid_moneytracker/core/result/result.dart';
import 'package:conveygrid_moneytracker/features/profile/domain/entities/user_profile.dart';
import 'package:conveygrid_moneytracker/features/profile/domain/usecases/profile_usecases.dart';
import 'package:conveygrid_moneytracker/features/profile/presentation/bloc/profile_bloc.dart';

class _MockSave extends Mock implements SaveProfileUseCase {}

class _MockUpdate extends Mock implements UpdateProfileUseCase {}

class _MockGet extends Mock implements GetProfileUseCase {}

void main() {
  late _MockSave save;
  late _MockUpdate update;
  late _MockGet get;

  setUp(() {
    save = _MockSave();
    update = _MockUpdate();
    get = _MockGet();
  });

  setUpAll(() {
    registerFallbackValue(
      UserProfile(
        id: '1',
        fullName: 'A',
        email: 'a@b.com',
        mobileNumber: '9876543210',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  });

  blocTest<ProfileBloc, ProfileState>(
    'enables continue only when profile is valid',
    build: () => ProfileBloc(
      saveProfile: save,
      updateProfile: update,
      getProfile: get,
    ),
    act: (bloc) {
      bloc
        ..add(const ProfileFullNameChanged('Alex Kumar'))
        ..add(const ProfileEmailChanged('alex@example.com'))
        ..add(const ProfileMobileChanged('9876543210'));
    },
    expect: () => [
      isA<ProfileState>().having((s) => s.isValid, 'valid', false),
      isA<ProfileState>().having((s) => s.isValid, 'valid', false),
      isA<ProfileState>().having((s) => s.isValid, 'valid', true),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'submits new profile and requests consent next',
    build: () {
      when(() => save(any())).thenAnswer(
        (invocation) async {
          final profile = invocation.positionalArguments.first as UserProfile;
          return Success(profile);
        },
      );
      return ProfileBloc(
        saveProfile: save,
        updateProfile: update,
        getProfile: get,
      );
    },
    seed: () => const ProfileState(
      fullName: 'Alex Kumar',
      email: 'alex@example.com',
      mobileNumber: '9876543210',
      isValid: true,
      status: ProfileStatus.editing,
    ),
    act: (bloc) => bloc.add(const ProfileSubmitted()),
    expect: () => [
      isA<ProfileState>()
          .having((s) => s.status, 'status', ProfileStatus.submitting),
      isA<ProfileState>().having(
        (s) => s.status,
        'status',
        ProfileStatus.readyForConsent,
      ),
    ],
  );
}
