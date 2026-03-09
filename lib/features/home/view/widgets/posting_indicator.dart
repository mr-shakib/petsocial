import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PostingIndicator extends StatelessWidget {
  final String? avatarUrl;
  final double progress; // 0.0 to 1.0

  const PostingIndicator({
    super.key,
    this.avatarUrl,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final thumbSize = w * 0.13;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.03, w * 0.04, w * 0.025),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(w * 0.02),
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl!,
                        width: thumbSize,
                        height: thumbSize,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(thumbSize, w),
                      )
                    : _placeholder(thumbSize, w),
              ),
              SizedBox(width: w * 0.035),
              Text(
                'posting...',
                style: TextStyle(
                  fontSize: w * 0.038,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.progressTrack,
          color: AppColors.primary,
          minHeight: 3,
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _placeholder(double size, double w) => Container(
        width: size,
        height: size,
        color: const Color(0xFFE0D5CE),
        child: Icon(Icons.pets, color: AppColors.textGrey, size: w * 0.05),
      );
}
