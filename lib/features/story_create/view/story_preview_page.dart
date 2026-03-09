import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/story_create_viewmodel.dart';

class StoryPreviewPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final state = ref.watch(storyCreateProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Preview image
            Image.file(
              File(filePath),
              fit: BoxFit.contain,
            ),

            // Close button
            Positioned(
              top: w * 0.04,
              left: w * 0.04,
              child: GestureDetector(
                onTap: state.isUploading ? null : () => context.pop(),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: w * 0.07,
                ),
              ),
            ),

            // Upload progress overlay
            if (state.isUploading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.white24,
                  color: AppColors.primary,
                  minHeight: 3,
                ),
              ),

            // Share button
            Positioned(
              bottom: h * 0.05,
              left: w * 0.06,
              right: w * 0.06,
              child: ElevatedButton(
                onPressed: state.isUploading ? null : () => _share(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                  minimumSize: Size(double.infinity, h * 0.066),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.14),
                  ),
                ),
                child: state.isUploading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: w * 0.03),
                          Text(
                            '${(state.progress * 100).toInt()}%',
                            style: GoogleFonts.workSans(
                              color: Colors.white,
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
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

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(storyCreateProvider.notifier).share(
          file: File(filePath),
          petId: petId,
          isVideo: isVideo,
        );

    if (success && context.mounted) {
      ref.read(storyCreateProvider.notifier).reset();
      // Pop all story screens back to home
      while (context.canPop()) {
        context.pop();
      }
    }
  }
}
