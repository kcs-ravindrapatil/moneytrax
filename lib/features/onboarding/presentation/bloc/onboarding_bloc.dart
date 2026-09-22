import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../settings/data/datasources/preferences_data_source.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._preferences) : super(const OnboardingState()) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPressed>(_onNext);
    on<OnboardingSkipPressed>(_onSkip);
    on<OnboardingCompleted>(_onCompleted);
  }

  final PreferencesDataSource _preferences;

  static const int totalPages = 3;

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(pageIndex: event.index));
  }

  void _onNext(OnboardingNextPressed event, Emitter<OnboardingState> emit) {
    if (state.pageIndex < totalPages - 1) {
      emit(state.copyWith(pageIndex: state.pageIndex + 1));
    } else {
      add(const OnboardingCompleted());
    }
  }

  void _onSkip(OnboardingSkipPressed event, Emitter<OnboardingState> emit) {
    add(const OnboardingCompleted());
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await _preferences.setIntroCompleted(true);
    emit(state.copyWith(completed: true));
  }
}
