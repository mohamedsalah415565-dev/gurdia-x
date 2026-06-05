// ==================== onboarding_bloc.dart ====================
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian_x/bloc/bloc_event.dart';
import 'package:guardian_x/bloc/bloc_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final int totalPages = 4;

  OnboardingBloc() : super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckStatus);
    on<PageChanged>(_onPageChanged);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<SkipOnboarding>(_onSkipOnboarding);
  }

  Future<void> _onCheckStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? completed = prefs.getBool('onboarding_completed');

      if (completed == true) {
        emit(OnboardingCompleted());
      } else {
        emit(OnboardingInProgress(currentIndex: 0, isLastPage: false));
      }
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  void _onPageChanged(
    PageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingInProgress(
      currentIndex: event.index,
      isLastPage: event.index == totalPages - 1,
    ));
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onSkipOnboarding(
    SkipOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
