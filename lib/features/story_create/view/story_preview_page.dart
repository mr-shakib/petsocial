import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    final ctrl = VideoPlayerController.file(File(widget.filePath));
    await ctrl.initialize();
    ctrl.setLooping(true);
    await ctrl.play();
    if (mounted) {
      setState(() {
        _videoCtrl = ctrl;
        _videoReady = true;
      });
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
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
            // Preview media
            _buildMedia(),

            // Close button
            Positioned(
              top: w * 0.04,
              left: w * 0.04,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: w * 0.07,
                ),
              ),
            ),

            // Video play/pause toggle
            if (widget.isVideo && _videoReady)
              Center(
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: AnimatedOpacity(
                    opacity: _videoCtrl?.value.isPlaying == true ? 0.0 : 1.0,
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

            // Share button
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
      if (!_videoReady || _videoCtrl == null) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      return GestureDetector(
        onTap: _togglePlay,
        child: Center(
          child: AspectRatio(
            aspectRatio: _videoCtrl!.value.aspectRatio,
            child: VideoPlayer(_videoCtrl!),
          ),
        ),
      );
    }
    return Image.file(File(widget.filePath), fit: BoxFit.contain);
  }

  void _togglePlay() {
    final ctrl = _videoCtrl;
    if (ctrl == null) return;
    setState(() {
      ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
    });
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    // Fire and forget — navigate to home immediately.
    // The PostingIndicator on the home page tracks real upload progress.
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
