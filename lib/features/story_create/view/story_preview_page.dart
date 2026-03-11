import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/story_create_viewmodel.dart';

class StoryPreviewPage extends ConsumerStatefulWidget {
  final String petId;
  final String filePath;
  final bool isVideo;

  const StoryPreviewPage({
    super.key,
    required this.petId,
    required this.filePath,
    required this.isVideo,
  });

  @override
  ConsumerState<StoryPreviewPage> createState() => _StoryPreviewPageState();
}

class _StoryPreviewPageState extends ConsumerState<StoryPreviewPage> {
  Player? _player;
  VideoController? _videoCtrl;
  bool _videoReady = false;
  bool _isPlaying = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final path = widget.filePath;
      final player = Player();
      final ctrl = VideoController(
        player,
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: false,
        ),
      );
      player.stream.error.listen((_) {
        if (mounted) setState(() => _videoError = true);
      });
      final media = path.startsWith('content://')
          ? Media(path)
          : Media(Uri.file(path).toString());
      await player.open(media);
      await player.play();
      await ctrl.waitUntilFirstFrameRendered;
      if (mounted) {
        setState(() {
          _player = player;
          _videoCtrl = ctrl;
          _videoReady = true;
          _isPlaying = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_player == null) return;
    setState(() {
      if (_isPlaying) {
        _player!.pause();
        _isPlaying = false;
      } else {
        _player!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMedia(),
            Positioned(
              top: w * 0.04,
              left: w * 0.04,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.close, color: Colors.white, size: w * 0.07),
              ),
            ),
            if (widget.isVideo && _videoReady)
              Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: EdgeInsets.all(w * 0.04),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: w * 0.12),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: h * 0.05,
              left: w * 0.06,
              right: w * 0.06,
              child: ElevatedButton(
                onPressed: () => _share(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, h * 0.066),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.14),
                  ),
                ),
                child: Text(
                  'Share',
                  style: GoogleFonts.workSans(
                    color: Colors.white,
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.isVideo) {
      if (_videoError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.videocam_outlined, color: Colors.white38, size: 64),
              SizedBox(height: 16),
              Text('Preview unavailable',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 8),
              Text('Your video will still upload correctly.',
                  style: TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        );
      }
      if (!_videoReady || _videoCtrl == null) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      }
      return GestureDetector(
        onTap: _togglePlay,
        child: Video(
          controller: _videoCtrl!,
          controls: NoVideoControls,
          fit: BoxFit.contain,
        ),
      );
    }
    return Image.file(File(widget.filePath), fit: BoxFit.contain);
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    // ignore: unawaited_futures
    ref.read(storyCreateProvider.notifier).share(
      file: File(widget.filePath),
      petId: widget.petId,
      isVideo: widget.isVideo,
    );
    if (context.mounted) {
      while (context.canPop()) {
        context.pop();
      }
    }
  }
}
