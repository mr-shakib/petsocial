import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PasswordInputField extends StatelessWidget {
  final TextEditingController controller;

  const PasswordInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password',
            style: TextStyle(
              fontSize: w * 0.036,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          SizedBox(height: h * 0.010),
          TextField(
            controller: controller,
            obscureText: true,
            style: TextStyle(fontSize: w * 0.038, color: AppColors.textBlack),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: '••••••••',
              hintStyle: TextStyle(color: AppColors.textGrey, fontSize: w * 0.038),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.04),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.04),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.04),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.022,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
