import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/feed_post_card.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_tabs.dart';
import 'widgets/posting_indicator.dart';
import 'widgets/story_bar.dart';

const _mockPosts = [
  (
    image: 'https://picsum.photos/seed/dog10/400/450',
    pet: 'Hunter',
    owner: 'Jacob William',
    avatar: 'https://picsum.photos/seed/av1/100/100',
    reactions: '12.3k',
    comments: '103',
  ),
  (
    image: 'https://picsum.photos/seed/dog11/400/450',
    pet: 'Luna',
    owner: 'Sarah Connor',
    avatar: 'https://picsum.photos/seed/av2/100/100',
    reactions: '8.1k',
    comments: '74',
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;
  int _navIndex = 0;

  // null = not uploading; 0.0–1.0 = upload progress
  double? _uploadProgress = 0.6;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeTabs(
              selectedIndex: _tabIndex,
              onTabChanged: (i) => setState(() => _tabIndex = i),
            ),
          ),
          SliverToBoxAdapter(
            child: StoryBar(
              onAddStory: () => context.push('/story/select-pet'),
            ),
          ),
          // Only rendered during active upload
          if (_uploadProgress != null)
            SliverToBoxAdapter(
              child: PostingIndicator(
                avatarUrl: 'https://picsum.photos/seed/av1/100/100',
                progress: _uploadProgress!,
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final p = _mockPosts[i % _mockPosts.length];
                return Padding(
                  padding: EdgeInsets.only(bottom: w * 0.04),
                  child: FeedPostCard(
                    imageUrl: p.image,
                    petName: p.pet,
                    ownerName: p.owner,
                    petAvatarUrl: p.avatar,
                    reactionCount: p.reactions,
                    commentCount: p.comments,
                  ),
                );
              },
              childCount: 6,
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavBar(
        selectedIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
