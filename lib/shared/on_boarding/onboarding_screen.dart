import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian_x/auth_gate.dart';
import 'package:guardian_x/bloc/bloc_bloc.dart';
import 'package:guardian_x/bloc/bloc_event.dart';
import 'package:guardian_x/bloc/bloc_state.dart';
import 'package:guardian_x/shared/colors/app_theme.dart';
import 'package:guardian_x/shared/on_boarding/onboarding_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBording extends StatelessWidget {
  const OnBording({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()..add(CheckOnboardingStatus()),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          _completeOnboarding();
        }
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          if (state is OnboardingLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is OnboardingError) {
            return Scaffold(
              body: Center(child: Text('Error: ${state.message}')),
            );
          }

          if (state is OnboardingInProgress) {
            return Scaffold(
              backgroundColor: AppTheme.white,
              appBar: AppBar(
                backgroundColor: AppTheme.white,
                elevation: 0,
                actions: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 19,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        itemCount: OnboardingData.pages.length,
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          context.read<OnboardingBloc>().add(
                            PageChanged(index),
                          );
                        },
                        itemBuilder: (context, index) =>
                            _buildOnboardingPage(OnboardingData.pages[index]),
                      ),
                    ),

                    const SizedBox(height: 10),

                    AnimatedSlide(
                      duration: const Duration(milliseconds: 500),
                      offset: state.isLastPage
                          ? Offset.zero
                          : const Offset(0, 1),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: state.isLastPage ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _completeOnboarding,
                              child: const Text(
                                'Ok',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    AnimatedSmoothIndicator(
                      activeIndex: state.currentIndex,
                      count: OnboardingData.pages.length,
                      effect: const ScrollingDotsEffect(
                        activeDotColor: Colors.black,
                        dotHeight: 10,
                        dotWidth: 10,
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Column(
      children: [
        const Spacer(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.asset(
            page.image,
            height: 260,
            width: 260,
            fit: BoxFit.contain,
          ),
        ),
        const Spacer(),

        // const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }
}
