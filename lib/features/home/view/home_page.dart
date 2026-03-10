import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/signalr_service.dart';
import '../../../core/services/token_service.dart';
import '../../story_create/viewmodel/story_create_viewmodel.dart';
import '../../story_view/model/story_view_data.dart';
import '../model/story_group_model.dart';
import '../viewmodel/home_viewmodel.dart';
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

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _tabIndex = 0;
  int _navIndex = 0;
  SignalRService? _signalR;

  @override
  void initState() {
    super.initState();
    _initSignalR();
  }

  Future<void> _initSignalR() async {
    final token = await TokenService.getToken();
    if (token == null) return;
    _signalR = SignalRService(
      onNewStory: () => ref.invalidate(homeStoryProvider),
    );
    await _signalR!.connect(token);
  }

  @override
  void dispose() {
    _signalR?.disconnect();
    super.dispose();
  }

  void _openStoryViewer(StoryGroupModel group) {
    final validStories =
        group.stories.where((s) => (s.image ?? s.video) != null).toList();
    if (validStories.isEmpty) return;

    context.push('/story/viewer', extra: StoryViewData(
      petName: group.petName,
      ownerName: group.ownerUsername,
      petAvatarUrl: group.petPictureUrl,
      mediaUrls: validStories.map((s) => s.image ?? s.video!).toList(),
      isVideo: validStories.map((s) => s.video != null).toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final storiesAsync = ref.watch(homeStoryProvider);
    final createState = ref.watch(storyCreateProvider);
    final userAvatarUrl = ref.watch(profilePictureProvider).valueOrNull;

    // Refresh story list and auto-hide posting indicator when upload finishes
    ref.listen<StoryCreateState>(storyCreateProvider, (prev, next) {
      if (prev?.isDone == false && next.isDone) {
        ref.invalidate(homeStoryProvider);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) ref.read(storyCreateProvider.notifier).reset();
        });
      }
    });

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
            child: storiesAsync.when(
              data: (stories) => StoryBar(
                onAddStory: () => context.push('/story/select-pet'),
                userAvatarUrl: userAvatarUrl,
                stories: stories,
                onStoryTap: _openStoryViewer,
              ),
              loading: () => StoryBar(
                onAddStory: () => context.push('/story/select-pet'),
                userAvatarUrl: userAvatarUrl,
                stories: const [],
                onStoryTap: (_) {},
              ),
              error: (_, __) => StoryBar(
                onAddStory: () => context.push('/story/select-pet'),
                userAvatarUrl: userAvatarUrl,
                stories: const [],
                onStoryTap: (_) {},
              ),
            ),
          ),
          if (createState.isUploading || createState.isDone)
            SliverToBoxAdapter(
              child: PostingIndicator(
                avatarUrl: null,
                progress: createState.progress,
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
