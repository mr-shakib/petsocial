import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';

class StoryCameraPreview extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final cam.CameraController? controller;
  final VoidCallback onRetry;
  final double w;

  const StoryCameraPreview({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.controller,
    required this.onRetry,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(w * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined,
                  color: Colors.white54, size: w * 0.15),
              SizedBox(height: w * 0.04),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white70, fontSize: w * 0.038),
              ),
              SizedBox(height: w * 0.06),
              TextButton(
                onPressed: errorMessage!.contains('Settings')
                    ? openAppSettings
                    : onRetry,
                child: Text(
                  errorMessage!.contains('Settings')
                      ? 'Open Settings'
                      : 'Retry',
                  style: TextStyle(
                      color: AppColors.primary, fontSize: w * 0.04),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final ctrl = controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: ctrl.value.previewSize!.height,
            height: ctrl.value.previewSize!.width,
            child: cam.CameraPreview(ctrl),
          ),
        ),
      ),
    );
  }
}
