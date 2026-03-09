import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(w * 0.02, h * 0.012, 0, 0),
          child: TextButton.icon(
            onPressed: () => context.go('/'),
            icon: Icon(Icons.arrow_back, color: AppColors.textBlack, size: w * 0.05),
            label: Text(
              'Back',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: w * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: h * 0.015),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your information',
                style: TextStyle(
                  fontSize: w * 0.067,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              SizedBox(height: h * 0.008),
              Text(
                'Provide your information to continue.',
                style: TextStyle(fontSize: w * 0.036, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
