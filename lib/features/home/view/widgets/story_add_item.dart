import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StoryAddItem extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onTap;

  const StoryAddItem({super.key, this.avatarUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cardW = w * 0.19;
    final cardH = w * 0.24;
    final radius = w * 0.04;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0D8D2), width: 1.5),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius - 1.5),
                  child: avatarUrl != null
                      ? Image.network(
                          avatarUrl!,
                          width: cardW,
                          height: cardH,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(cardW, cardH, w),
                        )
                      : _placeholder(cardW, cardH, w),
                ),
              ),
              // White ring + blue "+" badge
              Positioned(
                bottom: -w * 0.022,
                right: -w * 0.022,
                child: Container(
                  width: w * 0.088,
                  height: w * 0.088,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: AppColors.white, size: w * 0.042),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.038),
          Text(
            'You',
            style: TextStyle(
              fontSize: w * 0.028,
              color: AppColors.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(double cardW, double cardH, double w) => Container(
        width: cardW,
        height: cardH,
        color: const Color(0xFFE0D5CE),
        child: Icon(Icons.person, color: AppColors.textGrey, size: w * 0.08),
      );
}
