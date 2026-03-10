import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CameraControlsBar extends StatefulWidget {
  final VoidCallback onCapture;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;
  final Future<void> Function({required bool isVideo}) onGalleryPick;
  final bool isRecording;

  const CameraControlsBar({
    super.key,
    required this.onCapture,
    required this.onRecordStart,
    required this.onRecordStop,
    required this.onGalleryPick,
    required this.isRecording,
  });

  @override
  State<CameraControlsBar> createState() => _CameraControlsBarState();
}

class _CameraControlsBarState extends State<CameraControlsBar> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void didUpdateWidget(CameraControlsBar old) {
    super.didUpdateWidget(old);
    if (widget.isRecording && !old.isRecording) {
      _seconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    } else if (!widget.isRecording && old.isRecording) {
      _timer?.cancel();
      _timer = null;
      if (mounted) setState(() => _seconds = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showGallerySheet(BuildContext context, double w) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: w * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image_rounded),
                title: Text('Photo', style: TextStyle(fontSize: w * 0.04)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onGalleryPick(isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_rounded),
                title: Text('Video', style: TextStyle(fontSize: w * 0.04)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onGalleryPick(isVideo: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;

    return Positioned(
      bottom: h * 0.05,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Recording timer
          if (widget.isRecording)
            Padding(
              padding: EdgeInsets.only(bottom: h * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: w * 0.025,
                    height: w * 0.025,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  Text(
                    _timerLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Hint label
          if (!widget.isRecording)
            Padding(
              padding: EdgeInsets.only(bottom: h * 0.015),
              child: Text(
                'Tap for photo · Hold for video',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: w * 0.032,
                ),
              ),
            ),

          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left spacer balancing gallery button
              SizedBox(width: w * 0.13),
              SizedBox(width: w * 0.08),

              // Shutter / record button
              GestureDetector(
                onTap: widget.isRecording ? null : widget.onCapture,
                onLongPressStart: (_) => widget.onRecordStart(),
                onLongPressEnd: (_) => widget.onRecordStop(),
                child: Container(
                  width: w * 0.2,
                  height: w * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isRecording ? Colors.red : Colors.white,
                      width: 4,
                    ),
                    color: widget.isRecording
                        ? Colors.red.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                  child: widget.isRecording
                      ? Center(
                          child: Container(
                            width: w * 0.07,
                            height: w * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(w * 0.015),
                            ),
                          ),
                        )
                      : null,
                ),
              ),

              SizedBox(width: w * 0.08),

              // Gallery button
              GestureDetector(
                onTap: widget.isRecording
                    ? null
                    : () => _showGallerySheet(context, w),
                child: Container(
                  width: w * 0.13,
                  height: w * 0.13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 2),
                    color: Colors.white12,
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: widget.isRecording ? Colors.white30 : Colors.white70,
                    size: w * 0.055,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CameraIconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const CameraIconBtn({
    super.key,
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size * 0.3),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: size),
      ),
    );
  }
}
