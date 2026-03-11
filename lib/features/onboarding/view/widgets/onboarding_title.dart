import 'package:flutter/material.dart';

class OnboardingTitle extends StatelessWidget {
  const OnboardingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.06, h * 0.04, w * 0.06, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meet Your\nNew Friend',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: w * 0.108,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          SizedBox(height: h * 0.017),
          Text(
            'A fun and exciting new way to connect, play, and\nmake memories with your favorite pets',
            style: TextStyle(
              fontSize: w * 0.036,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
