import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({super.key});

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = "No cameras found on the device.";
          _isInitializing = false;
        });
        return;
      }

      // Try to find front camera
      final frontCam = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to open camera: $e";
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile file = await _controller!.takePicture();
      Get.back(result: File(file.path));
    } catch (e) {
      Get.snackbar(
        "Capture Error",
        "Failed to capture photo: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Selfie Verification"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _errorMessage = null;
                  });
                  _initializeCamera();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera Preview
              ClipRect(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),

              // Circular cutout overlay stencil
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(140),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Target frame outline
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 282,
                  height: 282,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 3),
                    borderRadius: BorderRadius.circular(141),
                  ),
                ),
              ),

              // Helper Text
              const Positioned(
                top: 40,
                child: Text(
                  "Position your face inside the circle",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),

              if (_isCapturing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),

        // Bottom Controls
        Container(
          height: 120,
          color: Colors.black,
          child: Center(
            child: GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
