import 'package:flutter/material.dart';

Future<void> showCameraGallerySheet(
  BuildContext context, {
  required Future<void> Function({required bool isVideo}) onPick,
  required double w,
}) {
  return showModalBottomSheet<void>(
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
                onPick(isVideo: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_rounded),
              title: Text('Video', style: TextStyle(fontSize: w * 0.04)),
              onTap: () {
                Navigator.pop(ctx);
                onPick(isVideo: true);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
