abstract class OnboardingEvent {}

class CheckOnboardingStatus extends OnboardingEvent {}

class PageChanged extends OnboardingEvent {
  final int index;
  PageChanged(this.index);
}

class CompleteOnboarding extends OnboardingEvent {}

class SkipOnboarding extends OnboardingEvent {}
