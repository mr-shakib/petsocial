import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class StoryCameraPage extends StatefulWidget {
  final String petId;
  const StoryCameraPage({super.key, required this.petId});

  @override
  State<StoryCameraPage> createState() => _StoryCameraPageState();
}

class _StoryCameraPageState extends State<StoryCameraPage> {
  final _picker = ImagePicker();
  bool _picking = false;

  Future<void> _pickFrom(ImageSource source) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (file != null && mounted) {
        context.push('/story/preview', extra: {
          'petId': widget.petId,
          'filePath': file.path,
          'isVideo': false,
        });
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: w * 0.04,
              left: w * 0.04,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.close, color: Colors.white, size: w * 0.07),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: h * 0.06,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shutter button
                  GestureDetector(
                    onTap: () => _pickFrom(ImageSource.camera),
                    child: Container(
                      width: w * 0.2,
                      height: w * 0.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: _picking
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : null,
                    ),
                  ),

                  SizedBox(width: w * 0.08),

                  // Gallery button
                  GestureDetector(
                    onTap: () => _pickFrom(ImageSource.gallery),
                    child: Container(
                      width: w * 0.145,
                      height: w * 0.145,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54, width: 2),
                        color: Colors.white12,
                      ),
                      child: ClipOval(
                        child: Icon(
                          Icons.photo_library_rounded,
                          color: Colors.white70,
                          size: w * 0.06,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
