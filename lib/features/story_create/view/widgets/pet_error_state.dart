import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PetErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final double w;

  const PetErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_outlined, color: AppColors.textGrey, size: w * 0.15),
            SizedBox(height: w * 0.04),
            Text(
              'Could not load your pets',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: w * 0.02),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey, fontSize: w * 0.035),
            ),
            SizedBox(height: w * 0.06),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(w * 0.4, w * 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.14),
                ),
              ),
              child: Text(
                'Try again',
                style: TextStyle(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
