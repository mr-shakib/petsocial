import 'package:flutter/material.dart';
import 'story_add_item.dart';
import 'story_item_card.dart';

class _MockStory {
  final String username;
  final String? imageUrl;
  final bool allSeen;
  const _MockStory({required this.username, this.imageUrl, this.allSeen = false});
}

const _mockStories = [
  _MockStory(username: 'CoolUser1', imageUrl: 'https://picsum.photos/seed/dog1/200/250'),
  _MockStory(username: 'CoolUser1', imageUrl: 'https://picsum.photos/seed/dog2/200/250'),
  _MockStory(username: 'CoolUser1', imageUrl: 'https://picsum.photos/seed/dog3/200/250'),
  _MockStory(username: 'CoolUser1', imageUrl: 'https://picsum.photos/seed/dog4/200/250', allSeen: true),
];

class StoryBar extends StatelessWidget {
  final VoidCallback onAddStory;

  const StoryBar({super.key, required this.onAddStory});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: w * 0.36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: w * 0.05),
        itemCount: _mockStories.length + 1,
        separatorBuilder: (_, i) => i == 0
            ? Row(
                children: [
                  SizedBox(width: w * 0.04),
                  Container(
                    width: 1,
                    height: w * 0.32,
                    color: const Color(0xFFE0D8D2),
                  ),
                  SizedBox(width: w * 0.04),
                ],
              )
            : SizedBox(width: w * 0.04),
        itemBuilder: (_, i) {
          if (i == 0) {
            return StoryAddItem(onTap: onAddStory);
          }
          final story = _mockStories[i - 1];
          return StoryItemCard(
            username: story.username,
            imageUrl: story.imageUrl,
            allSeen: story.allSeen,
            onTap: () {},
          );
        },
      ),
    );
  }
}
