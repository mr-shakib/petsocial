import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingButtons extends StatelessWidget {
  const OnboardingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.06, 0, w * 0.06, h * 0.048),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textBlack,
                minimumSize: Size(0, h * 0.066),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.workSans(
                  fontSize: w * 0.041,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(0, h * 0.066),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Login',
                style: GoogleFonts.workSans(
                  fontSize: w * 0.041,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
