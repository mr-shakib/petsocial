import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StoryItemCard extends StatelessWidget {
  final String username;
  final String? imageUrl;
  final bool allSeen;
  final VoidCallback onTap;

  const StoryItemCard({
    super.key,
    required this.username,
    this.imageUrl,
    required this.allSeen,
    required this.onTap,
  });

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
          // Gradient outer border
          Container(
            decoration: BoxDecoration(
              gradient: allSeen
                  ? const LinearGradient(
                      colors: [AppColors.storySeen, AppColors.storySeen],
                    )
                  : const LinearGradient(
                      colors: [AppColors.storyGradientTop, AppColors.storyGradientBottom],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              borderRadius: BorderRadius.circular(radius + 4),
            ),
            padding: const EdgeInsets.all(2.5),
            // White gap layer
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(radius + 1.5),
              ),
              padding: const EdgeInsets.all(2.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        width: cardW,
                        height: cardH,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(cardW, cardH, w),
                      )
                    : _placeholder(cardW, cardH, w),
              ),
            ),
          ),
          SizedBox(height: w * 0.018),
          Text(
            username,
            style: TextStyle(
              fontSize: w * 0.028,
              color: AppColors.textBlack,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _placeholder(double cardW, double cardH, double w) => Container(
        width: cardW,
        height: cardH,
        color: const Color(0xFFE8DDD7),
        child: Icon(Icons.pets, color: AppColors.textGrey, size: w * 0.07),
      );
}
