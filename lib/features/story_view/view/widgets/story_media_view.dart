import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../model/story_view_data.dart';

class StoryMediaView extends StatelessWidget {
  final StoryViewData data;
  final int current;
  final VideoController? videoCtrl;
  final bool videoReady;

  const StoryMediaView({
    super.key,
    required this.data,
    required this.current,
    required this.videoCtrl,
    required this.videoReady,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = data.isVideo.length > current && data.isVideo[current];
    if (isVideo) {
      final ctrl = videoCtrl;
      if (!videoReady || ctrl == null) {
        return const ColoredBox(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }
      return Video(
        controller: ctrl,
        controls: NoVideoControls,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      data.mediaUrls[current],
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
    );
  }
}
