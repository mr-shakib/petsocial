import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../model/story_view_data.dart';

export '../model/story_view_data.dart';

class StoryViewerPage extends StatefulWidget {
  final StoryViewData data;
  const StoryViewerPage({super.key, required this.data});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  int _current = 0;

  static const _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: _storyDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _advance();
      })
      ..forward();
  }

  void _advance() {
    if (_current < widget.data.mediaUrls.length - 1) {
      setState(() => _current++);
      _progressCtrl
        ..reset()
        ..forward();
    } else {
      if (mounted) context.pop();
    }
  }

  void _retreat() {
    if (_current > 0) {
      setState(() => _current--);
      _progressCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final data = widget.data;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) => d.localPosition.dx < w / 2 ? _retreat() : _advance(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story media
            Image.network(
              data.mediaUrls[_current],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
            ),

            // Progress bars
            Positioned(
              top: h * 0.055,
              left: w * 0.03,
              right: w * 0.03,
              child: Row(
                children: List.generate(data.mediaUrls.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.006),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: i < _current
                            ? _bar(1.0, w)
                            : i == _current
                                ? AnimatedBuilder(
                                    animation: _progressCtrl,
                                    builder: (_, __) =>
                                        _bar(_progressCtrl.value, w),
                                  )
                                : _bar(0.0, w),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pet info — top left
            Positioned(
              top: h * 0.08,
              left: w * 0.04,
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
                  Column(
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
                      Text(
                        data.ownerName,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: w * 0.033,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top-right: more + close
            Positioned(
              top: h * 0.08,
              right: w * 0.04,
              child: Row(
                children: [
                  Icon(Icons.more_horiz, color: Colors.white, size: w * 0.065),
                  SizedBox(width: w * 0.04),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.close, color: Colors.white, size: w * 0.065),
                  ),
                ],
              ),
            ),

            // Right-side actions
            Positioned(
              right: w * 0.04,
              bottom: h * 0.12,
              child: Column(
                children: [
                  Icon(Icons.pets, color: Colors.white, size: w * 0.065),
                  SizedBox(height: w * 0.06),
                  Icon(Icons.send_outlined, color: Colors.white, size: w * 0.065),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double value, double w) => LinearProgressIndicator(
        value: value,
        minHeight: 2.5,
        backgroundColor: Colors.white38,
        color: Colors.white,
      );
}
