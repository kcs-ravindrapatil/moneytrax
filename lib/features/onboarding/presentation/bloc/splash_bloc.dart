import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({
    required GetProfileUseCase getProfile,
    required PreferencesDataSource preferences,
  })  : _getProfile = getProfile,
        _preferences = preferences,
        super(const SplashInitial()) {
    on<SplashStarted>(_onStarted);
  }

  final GetProfileUseCase _getProfile;
  final PreferencesDataSource _preferences;

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final introDone = await _preferences.isIntroCompleted();
    final profileResult = await _getProfile();

    if (profileResult.isFailure) {
      emit(SplashFailure(profileResult.failureOrNull!.message));
      return;
    }

    final hasProfile = profileResult.dataOrNull != null;
    final sessionActive = await _preferences.isSessionActive();
    if (!introDone) {
      emit(const SplashNavigateToIntro());
    } else if (!hasProfile) {
      emit(const SplashNavigateToWelcome());
    } else if (!sessionActive) {
      emit(const SplashNavigateToWelcome());
    } else {
      emit(const SplashNavigateToHome());
    }
  }
}
