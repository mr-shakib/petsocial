import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LoginIllustration extends StatelessWidget {
  const LoginIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: h * 0.03),
        child: Container(
          width: w * 0.65,
          height: w * 0.65,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/login_cartoon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
