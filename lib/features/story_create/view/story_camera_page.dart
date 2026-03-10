import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';

class StoryCameraPage extends StatefulWidget {
  final String petId;
  const StoryCameraPage({super.key, required this.petId});

  @override
  State<StoryCameraPage> createState() => _StoryCameraPageState();
}

class _StoryCameraPageState extends State<StoryCameraPage>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _loading = true;
  String? _errorMessage;
  bool _capturing = false;
  bool _galleryOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Skip lifecycle handling while gallery picker is active — we manage
    // camera pause/resume manually inside _pickGallery to avoid texture conflicts.
    if (_galleryOpen) return;
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initControllerAt(_cameraIndex);
    }
  }

  Future<void> _initCamera() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    // Request camera permission first
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = status.isPermanentlyDenied
              ? 'Camera permission permanently denied.\nEnable it in Settings.'
              : 'Camera permission denied.';
        });
      }
      return;
    }

    try {
      _cameras = await availableCameras();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Could not access camera: $e';
        });
      }
      return;
    }

    if (_cameras.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'No camera found on this device.';
        });
      }
      return;
    }

    // Prefer back camera
    _cameraIndex = _cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    if (_cameraIndex < 0) _cameraIndex = 0;

    await _initControllerAt(_cameraIndex);
  }

  Future<void> _initControllerAt(int index) async {
    await _controller?.dispose();
    _controller = null;

    final ctrl = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = ctrl;

    try {
      await ctrl.initialize();
      if (mounted) setState(() => _loading = false);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Camera error: ${e.description}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Unexpected error: $e';
        });
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    final next = (_cameraIndex + 1) % _cameras.length;
    setState(() {
      _loading = true;
      _cameraIndex = next;
    });
    await _initControllerAt(next);
  }

  Future<void> _capture() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    try {
      final file = await ctrl.takePicture();
      if (mounted) {
        context.pushReplacement('/story/preview', extra: {
          'petId': widget.petId,
          'filePath': file.path,
          'isVideo': false,
        });
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _capturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture: ${e.description}')),
        );
      }
    }
  }

  Future<void> _pickGallery() async {
    // Pause camera manually before opening gallery to avoid texture conflicts
    _galleryOpen = true;
    await _controller?.dispose();
    _controller = null;

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
    );

    _galleryOpen = false;

    if (!mounted) return;

    if (file != null) {
      context.pushReplacement('/story/preview', extra: {
        'petId': widget.petId,
        'filePath': file.path,
        'isVideo': false,
      });
    } else {
      // User cancelled — reinitialize camera with fresh texture
      setState(() => _loading = true);
      await _initControllerAt(_cameraIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(w, h),

          // Top bar
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: w * 0.03,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _IconBtn(
                    icon: Icons.close,
                    size: w * 0.065,
                    onTap: () => context.pop(),
                  ),
                  if (_cameras.length > 1 && !_loading && _errorMessage == null)
                    _IconBtn(
                      icon: Icons.flip_camera_ios_rounded,
                      size: w * 0.065,
                      onTap: _flipCamera,
                    ),
                ],
              ),
            ),
          ),

          // Bottom controls — only show when camera is ready
          if (!_loading && _errorMessage == null)
            Positioned(
              bottom: h * 0.06,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left spacer (balances gallery button on right)
                  SizedBox(width: w * 0.13),

                  SizedBox(width: w * 0.08),

                  // Shutter button
                  GestureDetector(
                    onTap: _capture,
                    child: Container(
                      width: w * 0.2,
                      height: w * 0.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: _capturing
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

                  // Gallery button (right)
                  GestureDetector(
                    onTap: _pickGallery,
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
                        color: Colors.white70,
                        size: w * 0.055,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview(double w, double h) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(w * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.white54, size: w * 0.15),
              SizedBox(height: h * 0.02),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: w * 0.038),
              ),
              SizedBox(height: h * 0.03),
              if (_errorMessage!.contains('Settings'))
                TextButton(
                  onPressed: openAppSettings,
                  child: Text(
                    'Open Settings',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: w * 0.04,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _initCamera,
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: w * 0.04,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final ctrl = _controller;
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
            child: CameraPreview(ctrl),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.size, required this.onTap});

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
