import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../home/repository/story_repository.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../model/story_view_data.dart';
import 'widgets/story_action_buttons.dart';
import 'widgets/story_media_view.dart';
import 'widgets/story_options_sheet.dart';
import 'widgets/story_progress_bars.dart';
import 'widgets/story_viewer_header.dart';

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

  void _showMoreSheet() {
    _progressCtrl.stop();
    showStoryOptionsSheet(context, _deleteStory).then((_) {
      if (mounted) _progressCtrl.forward();
    });
  }

  Future<void> _deleteStory() async {
    final storyId = widget.data.storyIds[_current];
    try {
      await ref.read(homeStoryRepositoryProvider).deleteStory(storyId);
      if (mounted) {
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
                StoryMediaView(
                  data: data,
                  current: _current,
                  videoCtrl: _videoCtrl,
                  videoReady: _videoReady,
                ),
                StoryProgressBars(
                  count: data.mediaUrls.length,
                  current: _current,
                  animation: _progressCtrl,
                  w: w, h: h,
                ),
                StoryViewerHeader(
                  data: data,
                  current: _current,
                  timeAgo: data.createdAts.length > _current
                      ? StoryViewerHeader.formatTimeAgo(data.createdAts[_current])
                      : null,
                  onMore: _showMoreSheet,
                  onClose: () => context.pop(),
                  w: w, h: h,
                ),
                StoryActionButtons(w: w, h: h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
