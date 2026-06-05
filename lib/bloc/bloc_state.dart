abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingInProgress extends OnboardingState {
  final int currentIndex;
  final bool isLastPage;

  OnboardingInProgress({
    required this.currentIndex,
    required this.isLastPage,
  });
}

class OnboardingCompleted extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;
  OnboardingError(this.message);
}
