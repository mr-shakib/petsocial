import 'dart:async';
import 'package:flutter/material.dart';
import 'camera_gallery_sheet.dart';

export 'camera_icon_btn.dart';

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
          if (widget.isRecording)
            _RecordingTimerRow(w: w, h: h, timerLabel: _timerLabel),
          if (!widget.isRecording)
            Padding(
              padding: EdgeInsets.only(bottom: h * 0.015),
              child: Text(
                'Tap for photo · Hold for video',
                style: TextStyle(color: Colors.white60, fontSize: w * 0.032),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: w * 0.13),
              SizedBox(width: w * 0.08),
              _ShutterButton(
                isRecording: widget.isRecording,
                onCapture: widget.onCapture,
                onRecordStart: widget.onRecordStart,
                onRecordStop: widget.onRecordStop,
                w: w,
              ),
              SizedBox(width: w * 0.08),
              GestureDetector(
                onTap: widget.isRecording
                    ? null
                    : () => showCameraGallerySheet(
                          context,
                          onPick: widget.onGalleryPick,
                          w: w,
                        ),
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

class _RecordingTimerRow extends StatelessWidget {
  final double w;
  final double h;
  final String timerLabel;

  const _RecordingTimerRow(
      {required this.w, required this.h, required this.timerLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: w * 0.025,
            height: w * 0.025,
            decoration: const BoxDecoration(
                color: Colors.red, shape: BoxShape.circle),
          ),
          SizedBox(width: w * 0.02),
          Text(
            timerLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: w * 0.04,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onCapture;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;
  final double w;

  const _ShutterButton({
    required this.isRecording,
    required this.onCapture,
    required this.onRecordStart,
    required this.onRecordStop,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRecording ? null : onCapture,
      onLongPressStart: (_) => onRecordStart(),
      onLongPressEnd: (_) => onRecordStop(),
      child: Container(
        width: w * 0.2,
        height: w * 0.2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isRecording ? Colors.red : Colors.white,
            width: 4,
          ),
          color: isRecording
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.15),
        ),
        child: isRecording
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
    );
  }
}
