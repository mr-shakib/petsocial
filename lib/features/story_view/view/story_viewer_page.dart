import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/repository/story_repository.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../model/story_view_data.dart';

export '../model/story_view_data.dart';

class StoryViewerPage extends ConsumerStatefulWidget {
  final StoryViewData data;
  const StoryViewerPage({super.key, required this.data});

  @override
  ConsumerState<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends ConsumerState<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  int _current = 0;
  double _dragY = 0;
  double _dragScale = 1.0;
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _isPaused = false;

  static const _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: _storyDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _advance();
      });
    _initMediaForCurrent();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  Future<void> _initMediaForCurrent() async {
    await _videoCtrl?.dispose();
    _videoCtrl = null;

    final data = widget.data;
    final isVideo = data.isVideo.length > _current && data.isVideo[_current];

    if (isVideo) {
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(data.mediaUrls[_current]),
      );
      _videoCtrl = ctrl;
      await ctrl.initialize();
      final vd = ctrl.value.duration;
      _progressCtrl.duration = vd > const Duration(seconds: 2)
          ? (vd < const Duration(seconds: 60) ? vd : const Duration(seconds: 60))
          : _storyDuration;
      await ctrl.play();
      if (mounted) setState(() => _videoReady = true);
    } else {
      _progressCtrl.duration = _storyDuration;
    }

    if (mounted) _progressCtrl..reset()..forward();
  }

  void _advance() {
    if (_current < widget.data.mediaUrls.length - 1) {
      setState(() { _current++; _videoReady = false; });
      _initMediaForCurrent();
    } else {
      if (mounted) context.pop();
    }
  }

  void _retreat() {
    if (_current > 0) {
      setState(() { _current--; _videoReady = false; });
      _initMediaForCurrent();
    }
  }

  void _pause() {
    if (_isPaused) return;
    setState(() => _isPaused = true);
    _progressCtrl.stop();
    _videoCtrl?.pause();
  }

  void _resume() {
    if (!_isPaused) return;
    setState(() => _isPaused = false);
    _progressCtrl.forward();
    _videoCtrl?.play();
  }

  String _timeAgo(String iso) {
    // Server returns UTC timestamps without 'Z' — append it so Dart parses as UTC
    final normalized = iso.endsWith('Z') || iso.contains('+') ? iso : '${iso}Z';
    final dt = DateTime.tryParse(normalized);
    if (dt == null) return '';
    final diff = DateTime.now().toUtc().difference(dt.toUtc());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showMoreSheet() {
    _progressCtrl.stop();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Delete story',
              style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(ctx);
            _deleteStory();
          },
        ),
      ),
    ).then((_) {
      if (mounted) _progressCtrl.forward();
    });
  }

  Widget _buildMedia(StoryViewData data) {
    final isVideo = data.isVideo.length > _current && data.isVideo[_current];
    if (isVideo) {
      final ctrl = _videoCtrl;
      if (!_videoReady || ctrl == null) {
        return const ColoredBox(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }
      return Center(
        child: AspectRatio(
          aspectRatio: ctrl.value.aspectRatio,
          child: VideoPlayer(ctrl),
        ),
      );
    }
    return Image.network(
      data.mediaUrls[_current],
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
    );
  }

  Future<void> _deleteStory() async {
    final storyId = widget.data.storyIds[_current];
    try {
      await ref.read(homeStoryRepositoryProvider).deleteStory(storyId);
      if (mounted) {
        // Pop first, then invalidate — avoids story bar flashing empty
        // while the re-fetch is in flight
        context.pop();
        ref.invalidate(homeStoryProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final data = widget.data;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (d) => d.localPosition.dx < w / 2 ? _retreat() : _advance(),
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragUpdate: (d) {
          if (d.delta.dy > 0) {
            setState(() {
              _dragY += d.delta.dy;
              _dragScale = (1.0 - _dragY / (h * 3)).clamp(0.7, 1.0);
            });
          }
        },
        onVerticalDragEnd: (d) {
          if (_dragY > h * 0.2 || d.velocity.pixelsPerSecond.dy > 500) {
            context.pop();
          } else {
            setState(() { _dragY = 0; _dragScale = 1.0; });
          }
        },
        child: Transform.translate(
          offset: Offset(0, _dragY),
          child: Transform.scale(
            scale: _dragScale,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildMedia(data),
                _ProgressBars(
                  count: data.mediaUrls.length,
                  current: _current,
                  animation: _progressCtrl,
                  w: w, h: h,
                ),
                _StoryHeader(
                  data: data,
                  current: _current,
                  timeAgo: data.createdAts.length > _current
                      ? _timeAgo(data.createdAts[_current])
                      : null,
                  onMore: _showMoreSheet,
                  onClose: () => context.pop(),
                  w: w, h: h,
                ),
                Positioned(
                  right: w * 0.04,
                  bottom: h * 0.12,
                  child: Column(
                    children: [
                      Icon(Icons.pets, color: Colors.white, size: w * 0.065),
                      SizedBox(height: w * 0.06),
                      Icon(Icons.send_outlined,
                          color: Colors.white, size: w * 0.065),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  final int count;
  final int current;
  final Animation<double> animation;
  final double w;
  final double h;

  const _ProgressBars({
    required this.count, required this.current,
    required this.animation, required this.w, required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: h * 0.055,
      left: w * 0.03,
      right: w * 0.03,
      child: Row(
        children: List.generate(count, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.006),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: i < current
                  ? _bar(1.0)
                  : i == current
                      ? AnimatedBuilder(
                          animation: animation,
                          builder: (_, __) => _bar(animation.value),
                        )
                      : _bar(0.0),
            ),
          ),
        )),
      ),
    );
  }

  Widget _bar(double value) => LinearProgressIndicator(
        value: value,
        minHeight: 2.5,
        backgroundColor: Colors.white38,
        color: Colors.white,
      );
}

class _StoryHeader extends StatelessWidget {
  final StoryViewData data;
  final int current;
  final String? timeAgo;
  final VoidCallback onMore;
  final VoidCallback onClose;
  final double w;
  final double h;

  const _StoryHeader({
    required this.data, required this.current, this.timeAgo,
    required this.onMore, required this.onClose,
    required this.w, required this.h,
  });

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
