import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../model/story_view_data.dart';

class StoryViewerHeader extends StatelessWidget {
  final StoryViewData data;
  final int current;
  final String? timeAgo;
  final VoidCallback onMore;
  final VoidCallback onClose;
  final double w;
  final double h;

  const StoryViewerHeader({
    super.key,
    required this.data,
    required this.current,
    this.timeAgo,
    required this.onMore,
    required this.onClose,
    required this.w,
    required this.h,
  });

  static String formatTimeAgo(String iso) {
    final normalized =
        iso.endsWith('Z') || iso.contains('+') ? iso : '${iso}Z';
    final dt = DateTime.tryParse(normalized);
    if (dt == null) return '';
    final diff = DateTime.now().toUtc().difference(dt.toUtc());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: h * 0.08,
      left: w * 0.04,
      right: w * 0.04,
      child: Row(
        children: [
          CircleAvatar(
            radius: w * 0.055,
            backgroundImage: data.petAvatarUrl != null
                ? NetworkImage(data.petAvatarUrl!)
                : null,
            backgroundColor: AppColors.primaryLight,
            child: data.petAvatarUrl == null
                ? Icon(Icons.pets, color: Colors.white, size: w * 0.05)
                : null,
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.petName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      data.ownerName,
                      style: TextStyle(
                          color: Colors.white70, fontSize: w * 0.033),
                    ),
                    if (timeAgo != null)
                      Text(
                        ' · $timeAgo',
                        style: TextStyle(
                            color: Colors.white54, fontSize: w * 0.033),
                      ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMore,
            child: Icon(Icons.more_horiz,
                color: Colors.white, size: w * 0.065),
          ),
          SizedBox(width: w * 0.04),
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close, color: Colors.white, size: w * 0.065),
          ),
        ],
      ),
    );
  }
}
