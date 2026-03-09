import 'package:flutter/material.dart';
import 'widgets/onboarding_buttons.dart';
import 'widgets/onboarding_title.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF25912),
              Color(0x99F25912),
              Color(0x4DF25912),
            ],
            stops: [0.0, 0.5096, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingTitle(),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/onboarding_cartoon.png',
                    width: w * 0.85,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const OnboardingButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
