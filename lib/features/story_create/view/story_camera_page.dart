import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/camera_controls_bar.dart';
import 'widgets/camera_preview.dart';

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
  bool _galleryOpen = false;
  bool _isRecording = false;

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
    final statuses = await [Permission.camera, Permission.microphone].request();
    if (statuses[Permission.camera]?.isGranted != true) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = statuses[Permission.camera]?.isPermanentlyDenied == true
            ? 'Camera permission permanently denied.\nEnable it in Settings.'
            : 'Camera permission denied.';
      });
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
      ResolutionPreset.medium,
      enableAudio: true,
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
    if (_cameras.length < 2 || _isRecording) return;
    final next = (_cameraIndex + 1) % _cameras.length;
    setState(() {
      _loading = true;
      _cameraIndex = next;
    });
    await _initControllerAt(next);
  }

  Future<void> _capturePhoto() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture: ${e.description}')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _isRecording) return;
    setState(() => _isRecording = true);
    try {
      await ctrl.startVideoRecording();
    } on CameraException catch (_) {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    final ctrl = _controller;
    if (ctrl == null || !_isRecording || !ctrl.value.isRecordingVideo) return;
    try {
      final file = await ctrl.stopVideoRecording();
      if (mounted) {
        setState(() => _isRecording = false);
        context.pushReplacement('/story/preview', extra: {
          'petId': widget.petId,
          'filePath': file.path,
          'isVideo': true,
        });
      }
    } on CameraException catch (_) {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  Future<void> _pickGallery({required bool isVideo}) async {
    _galleryOpen = true;
    await _controller?.dispose();
    _controller = null;
    XFile? file;
    if (isVideo) {
      file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    } else {
      file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );
    }
    _galleryOpen = false;
    if (!mounted) return;
    if (file != null) {
      context.pushReplacement('/story/preview', extra: {
        'petId': widget.petId,
        'filePath': file.path,
        'isVideo': isVideo,
      });
    } else {
      setState(() => _loading = true);
      await _initControllerAt(_cameraIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          StoryCameraPreview(
            isLoading: _loading,
            errorMessage: _errorMessage,
            controller: _controller,
            onRetry: _initCamera,
            w: w,
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: w * 0.03,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_isRecording)
                    CameraIconBtn(
                      icon: Icons.close,
                      size: w * 0.065,
                      onTap: () => context.pop(),
                    )
                  else
                    const SizedBox.shrink(),
                  if (_cameras.length > 1 &&
                      !_loading &&
                      _errorMessage == null &&
                      !_isRecording)
                    CameraIconBtn(
                      icon: Icons.flip_camera_ios_rounded,
                      size: w * 0.065,
                      onTap: _flipCamera,
                    ),
                ],
              ),
            ),
          ),
          if (!_loading && _errorMessage == null)
            CameraControlsBar(
              onCapture: _capturePhoto,
              onRecordStart: _startRecording,
              onRecordStop: _stopRecording,
              onGalleryPick: _pickGallery,
              isRecording: _isRecording,
            ),
        ],
      ),
    );
  }

}
