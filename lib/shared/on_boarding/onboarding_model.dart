class OnboardingPage {
  final String image;
  final String title;

  const OnboardingPage({
    required this.image,
    required this.title,
  });
}

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      image: 'assets/images/first_boarding.png',
      title: 'Always Watching. Always Protecting',
    ),
    OnboardingPage(
      image: 'assets/images/second_boarding.png',
      title: 'Stay Safe with Real-time Monitoring',
    ),
    OnboardingPage(
      image: 'assets/images/third_boarding.png',
      title: 'The SOS button lets you request help instantly with one tap',
    ),
    OnboardingPage(
      image: 'assets/images/fourth_boarding.png',
      title: 'This application helps promote peace within the community.',
    ),
  ];
}
