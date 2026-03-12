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
import 'widgets/story_section.dart';

const _mockPosts = [
  (
    image: 'https://place.dog/400/450',
    pet: 'Hunter',
    owner: 'Jacob William',
    avatar: 'https://place.dog/100/100',
    reactions: '12.3k',
    comments: '103',
  ),
  (
    image: 'https://placekitten.com/400/450',
    pet: 'Luna',
    owner: 'Sarah Connor',
    avatar: 'https://placekitten.com/100/100',
    reactions: '8.1k',
    comments: '74',
  ),
  (
    image: 'https://place.dog/401/450',
    pet: 'Max',
    owner: 'Emily Davis',
    avatar: 'https://place.dog/101/100',
    reactions: '5.2k',
    comments: '48',
  ),
  (
    image: 'https://placekitten.com/401/450',
    pet: 'Bella',
    owner: 'Chris Brown',
    avatar: 'https://placekitten.com/101/100',
    reactions: '9.7k',
    comments: '91',
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
  ProviderSubscription<StoryCreateState>? _uploadSub;

  @override
  void initState() {
    super.initState();
    _initSignalR();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uploadSub = ref.listenManual<StoryCreateState>(
        storyCreateProvider,
        (prev, next) {
          if (prev?.isDone == false && next.isDone) {
            ref.invalidate(homeStoryProvider);
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) ref.read(storyCreateProvider.notifier).reset();
            });
          }
          if (prev?.error == null && next.error != null) {
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.sizeOf(context).width * 0.05,
                  ),
                ),
                title: const Text('Upload Failed'),
                content: Text(next.error!),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(storyCreateProvider.notifier).reset();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    });
  }

  void _showComingSoon() {
    final w = MediaQuery.sizeOf(context).width;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          children: [
            const Text('🚧', style: TextStyle(fontSize: 16)),
            SizedBox(width: w * 0.03),
            const Text('This feature is coming soon!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.03),
        ),
      ));
  }

  void _onNavTap(int i) {
    if (i == 0) {
      setState(() => _navIndex = 0);
    } else {
      _showComingSoon();
    }
  }

  void _onTabChanged(int i) {
    if (i == 0) {
      setState(() => _tabIndex = 0);
    } else {
      _showComingSoon();
    }
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
    _uploadSub?.close();
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
      storyIds: validStories.map((s) => s.id).toList(),
      mediaUrls: validStories.map((s) => s.image ?? s.video!).toList(),
      isVideo: validStories.map((s) => s.video != null).toList(),
      createdAts: validStories.map((s) => s.createdAt).toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final createState = ref.watch(storyCreateProvider);
    final userAvatarUrl = ref.watch(profilePictureProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        onRefresh: () async {
          ref.invalidate(homeStoryProvider);
          // Wait for the new fetch to complete before dismissing the indicator
          await ref.read(homeStoryProvider.future).catchError((_) => <StoryGroupModel>[]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverToBoxAdapter(
            child: HomeTabs(
              selectedIndex: _tabIndex,
              onTabChanged: _onTabChanged,
            ),
          ),
          SliverToBoxAdapter(
            child: StorySection(
              onAddStory: () => context.push('/story/select-pet'),
              onStoryTap: _openStoryViewer,
              userAvatarUrl: userAvatarUrl,
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
      ),
      bottomNavigationBar: HomeBottomNavBar(
        selectedIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
