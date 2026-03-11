import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/model/story_group_model.dart';
import '../../../home/viewmodel/home_viewmodel.dart';
import 'story_bar.dart';

class StorySection extends ConsumerWidget {
  final VoidCallback onAddStory;
  final void Function(StoryGroupModel) onStoryTap;
  final String? userAvatarUrl;

  const StorySection({
    super.key,
    required this.onAddStory,
    required this.onStoryTap,
    required this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.sizeOf(context).width;
    final storiesAsync = ref.watch(homeStoryProvider);

    return storiesAsync.when(
      data: (stories) => StoryBar(
        onAddStory: onAddStory,
        userAvatarUrl: userAvatarUrl,
        stories: stories,
        onStoryTap: onStoryTap,
      ),
      loading: () => StoryBar(
        onAddStory: onAddStory,
        userAvatarUrl: userAvatarUrl,
        stories: const [],
        onStoryTap: (_) {},
      ),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoryBar(
            onAddStory: onAddStory,
            userAvatarUrl: userAvatarUrl,
            stories: const [],
            onStoryTap: (_) {},
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.05, vertical: w * 0.02),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.red[400], size: w * 0.045),
                SizedBox(width: w * 0.02),
                Expanded(
                  child: Text(
                    'Could not load stories',
                    style: TextStyle(
                        color: AppColors.textGrey, fontSize: w * 0.035),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(homeStoryProvider),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
