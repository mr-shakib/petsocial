import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback? onNext;
  final bool isLoading;

  const LoginFooter({super.key, required this.onNext, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, h * 0.066),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(w * 0.14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Next',
                    style: GoogleFonts.workSans(
                      fontSize: w * 0.041,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: h * 0.025),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: w * 0.036, color: AppColors.textGrey),
            children: const [
              TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Sign up',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: h * 0.04),
      ],
    );
  }
}
