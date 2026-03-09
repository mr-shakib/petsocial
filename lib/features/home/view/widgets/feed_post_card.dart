import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class FeedPostCard extends StatelessWidget {
  final String imageUrl;
  final String petName;
  final String ownerName;
  final String? petAvatarUrl;
  final String reactionCount;
  final String commentCount;

  const FeedPostCard({
    super.key,
    required this.imageUrl,
    required this.petName,
    required this.ownerName,
    this.petAvatarUrl,
    this.reactionCount = '0',
    this.commentCount = '0',
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(w * 0.04),
        child: Stack(
          children: [
            // Post image
            Image.network(
              imageUrl,
              width: double.infinity,
              height: w * 1.1,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: w * 1.1,
                color: const Color(0xFFE0D5CE),
                child: Icon(Icons.pets, color: AppColors.textGrey, size: w * 0.2),
              ),
            ),

            // Bottom gradient overlay
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: w * 0.5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xDD000000), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Pet info bottom-left
            Positioned(
              bottom: w * 0.05,
              left: w * 0.04,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: w * 0.055,
                    backgroundImage: petAvatarUrl != null ? NetworkImage(petAvatarUrl!) : null,
                    backgroundColor: AppColors.primaryLight,
                    child: petAvatarUrl == null
                        ? Icon(Icons.pets, color: Colors.white, size: w * 0.05)
                        : null,
                  ),
                  SizedBox(width: w * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        petName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: w * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ownerName,
                        style: TextStyle(color: Colors.white70, fontSize: w * 0.033),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons — social SVG icons
            Positioned(
              bottom: w * 0.04,
              right: w * 0.04,
              child: Column(
                children: [
                  _SvgAction(path: 'assets/social_icons/like.svg', label: reactionCount, w: w),
                  SizedBox(height: w * 0.05),
                  _SvgAction(path: 'assets/social_icons/comment.svg', label: commentCount, w: w),
                  SizedBox(height: w * 0.05),
                  _SvgAction(path: 'assets/social_icons/share.svg', label: '', w: w),
                  SizedBox(height: w * 0.05),
                  _SvgAction(path: 'assets/social_icons/repost.svg', label: '', w: w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SvgAction extends StatelessWidget {
  final String path;
  final String label;
  final double w;

  const _SvgAction({required this.path, required this.label, required this.w});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          path,
          width: w * 0.065,
          height: w * 0.065,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: w * 0.01),
          Text(label, style: TextStyle(color: Colors.white, fontSize: w * 0.03)),
        ],
      ],
    );
  }
}
