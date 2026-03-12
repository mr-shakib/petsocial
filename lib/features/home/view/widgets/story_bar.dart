import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../model/story_group_model.dart';
import 'story_add_item.dart';
import 'story_item_card.dart';

class StoryBar extends StatelessWidget {
  final VoidCallback onAddStory;
  final String? userAvatarUrl;
  final List<StoryGroupModel> stories;
  final void Function(StoryGroupModel group) onStoryTap;

  const StoryBar({
    super.key,
    required this.onAddStory,
    this.userAvatarUrl,
    required this.stories,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Container(
      height: w * 0.38,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.progressTrack, width: 1),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: w * 0.05),
        itemCount: stories.length + 1,
        separatorBuilder: (_, i) => i == 0
            ? Row(
                children: [
                  SizedBox(width: w * 0.04),
                  // Bar height = w*0.38, card height = w*0.277, card centre = w*0.1385.
                  // Alignment(0, -0.792) places the divider centre at w*0.1385.
                  SizedBox(
                    height: double.infinity,
                    child: Align(
                      alignment: const Alignment(0, -0.792),
                      child: Container(
                        width: 1,
                        height: w * 0.28,
                        color: AppColors.progressTrack,
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                ],
              )
            : SizedBox(width: w * 0.04),
        itemBuilder: (_, i) {
          if (i == 0) {
            return StoryAddItem(avatarUrl: userAvatarUrl, onTap: onAddStory);
          }
          final group = stories[i - 1];
          final firstStory =
              group.stories.isNotEmpty ? group.stories.first : null;
          final isVideo = firstStory?.video != null && firstStory?.image == null;
          final thumbUrl = isVideo ? group.petPictureUrl : firstStory?.image;

          return StoryItemCard(
            username: group.petName,
            imageUrl: thumbUrl,
            allSeen: group.allSeen,
            onTap: () => onStoryTap(group),
          );
        },
      ),
    );
  }
}
