import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'selfie_capture_screen.dart';
import 'generic_camera_capture_screen.dart';

class WorkImageCaptureScreen extends StatefulWidget {
  final bool isStartingWork;
  const WorkImageCaptureScreen({super.key, required this.isStartingWork});

  @override
  State<WorkImageCaptureScreen> createState() => _WorkImageCaptureScreenState();
}

class _WorkImageCaptureScreenState extends State<WorkImageCaptureScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _capturedImages = [];
  final TextEditingController _travelMeterController = TextEditingController();
  bool _isProcessingSelfie = false;
  bool _selfieValidated = false;

  String? _locationString;
  bool _isFetchingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _travelMeterController.addListener(() {
      setState(() {}); // Rebuild to update submit button state
    });
    _initiateLocationFetch();
  }

  Future<void> _initiateLocationFetch() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = "Location services disabled.";
          _isFetchingLocation = false;
        });
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = "Location permission denied.";
            _isFetchingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = "Location permissions permanently denied.";
          _isFetchingLocation = false;
        });
        return;
      }

      // 1. Try to get last known position first (fast)
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        setState(() {
          _locationString = "${lastKnown.latitude},${lastKnown.longitude}";
        });
      }

      // 2. Try to get fresh position
      Position? freshPosition;
      try {
        freshPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        ).timeout(const Duration(seconds: 20));
      } catch (e) {
        log("⚠️ High accuracy timeout, trying medium accuracy...", name: 'employee_tracking');
        try {
          freshPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
            ),
          ).timeout(const Duration(seconds: 10));
        } catch (e2) {
          log("❌ Medium accuracy also failed/timed out: $e2", name: 'employee_tracking');
        }
      }

      if (freshPosition != null) {
        setState(() {
          _locationString = "${freshPosition!.latitude},${freshPosition!.longitude}";
          _isFetchingLocation = false;
        });
      } else if (_locationString != null) {
        // Fresh position failed but we have last known position, so we are fine
        setState(() {
          _isFetchingLocation = false;
        });
      } else {
        // Both failed and no last known position
        setState(() {
          _locationError = "Failed to fetch GPS coordinates. Please move to an open area or retry.";
          _isFetchingLocation = false;
        });
      }
    } catch (e) {
      if (_locationString != null) {
        setState(() {
          _isFetchingLocation = false;
        });
      } else {
        setState(() {
          _locationError = "Failed to get location: $e";
          _isFetchingLocation = false;
        });
      }
    }
  }

  void _showLocationServiceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              "GPS is Disabled",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          "Your device's location services (GPS) are turned off. Please enable them to verify your location.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Open Settings"),
            onPressed: () async {
              Get.back();
              await Geolocator.openLocationSettings();
              _initiateLocationFetch();
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildLocationStatusCard() {
    Color cardColor = Colors.orange.shade50;
    Color borderColor = Colors.orange.shade200;
    Widget leading = SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.orange.shade800,
      ),
    );
    String title = "Fetching current location...";
    String subtitle = "Please keep GPS turned on";

    if (_locationString != null) {
      cardColor = Colors.green.shade50;
      borderColor = Colors.green.shade200;
      leading = Icon(Icons.location_on, color: Colors.green.shade700, size: 20);
      title = "Location captured successfully";
      subtitle = "Coordinates: $_locationString";
    } else if (_locationError != null) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      leading = Icon(Icons.error_outline, color: Colors.red.shade700, size: 20);
      title = "Location fetch failed";
      subtitle = _locationError!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (_locationError != null || (!_isFetchingLocation && _locationString == null))
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Colors.blue.shade700,
              onPressed: _initiateLocationFetch,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _travelMeterController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selfieValidated &&
        _capturedImages.length > 1 &&
        _travelMeterController.text.trim().isNotEmpty;
  }

  Future<void> _captureSelfie() async {
    final File? imageFile = await Get.to<File?>(() => const SelfieCaptureScreen());

    if (imageFile == null) return;

    setState(() {
      _isProcessingSelfie = true;
    });

    final hasFace = await _containsFace(imageFile);

    setState(() {
      _isProcessingSelfie = false;
    });

    if (hasFace) {
      setState(() {
        if (_capturedImages.isNotEmpty) {
          _capturedImages[0] = imageFile;
        } else {
          _capturedImages.add(imageFile);
        }
        _selfieValidated = true;
      });
      Get.snackbar(
        "Success",
        "Selfie validated successfully.",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      Get.snackbar(
        "Invalid Selfie",
        "No face detected. Please take a clear selfie.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> _captureAdditionalImage() async {
    final File? capturedFile = await Get.to<File?>(
      () => const GenericCameraCaptureScreen(title: "Capture Work Image"),
    );

    if (capturedFile != null) {
      setState(() {
        _capturedImages.add(capturedFile);
      });
    }
  }

  Future<bool> _containsFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: false,
      ),
    );

    try {
      final faces = await faceDetector.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (e) {
      log("❌ Error in face detection: $e", name: 'employee_tracking');
      return false;
    } finally {
      faceDetector.close();
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    if (_isFetchingLocation) {
      Get.snackbar(
        "Please wait",
        "Fetching your current location...",
        backgroundColor: Colors.blue.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_locationString == null) {
      Get.snackbar(
        "Location Required",
        "Attempting to fetch location again...",
        backgroundColor: Colors.orange.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
      await _initiateLocationFetch();
      if (_locationString == null) {
        Get.snackbar(
          "Error",
          _locationError ?? "Could not retrieve your location. Please check settings.",
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    int travelMeter = int.tryParse(_travelMeterController.text.trim()) ?? 0;
    Get.back(
      result: {
        'images': _capturedImages,
        'travel_meter': travelMeter,
        'location': _locationString,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: Text(widget.isStartingWork ? 'Start Work' : 'End Work'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLocationStatusCard(),
                    _buildStepCard(
                      stepNumber: 1,
                      title: 'Selfie Verification',
                      subtitle:
                          'A clear selfie is required to verify your identity.',
                      isCompleted: _selfieValidated,
                      child: _buildSelfieSection(),
                    ),
                    const SizedBox(height: 16),
                    _buildStepCard(
                      stepNumber: 2,
                      title: 'Vehicle & Work Images',
                      subtitle:
                          'At least one vehicle meter or work image is required.',
                      isCompleted: _capturedImages.length > 1,
                      isLocked: !_selfieValidated,
                      child: _buildAdditionalImagesSection(),
                    ),
                    const SizedBox(height: 16),
                    _buildStepCard(
                      stepNumber: 3,
                      title: 'Travel Meter Reading',
                      subtitle: 'Enter your current vehicle meter reading.',
                      isCompleted:
                          _travelMeterController.text.trim().isNotEmpty,
                      isLocked: !_selfieValidated,
                      child: _buildTravelMeterSection(),
                    ),
                    const SizedBox(height: 40), // padding at bottom
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isLocked = false,
    required Widget child,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLocked ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isCompleted ? Colors.green.shade300 : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                            : Text(
                              stepNumber.toString(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLocked) ...[const SizedBox(height: 20), child],
          ],
        ),
      ),
    );
  }

  Widget _buildSelfieSection() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: _selfieValidated ? Colors.green : Colors.grey.shade300,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                _isProcessingSelfie
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                    : _capturedImages.isNotEmpty && _selfieValidated
                    ? ClipOval(
                      child: Image.file(_capturedImages[0], fit: BoxFit.cover),
                    )
                    : const Center(
                      child: Icon(Icons.face, size: 60, color: Colors.grey),
                    ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isProcessingSelfie ? null : _captureSelfie,
            icon: Icon(
              _selfieValidated ? Icons.refresh : Icons.camera_alt,
              size: 20,
            ),
            label: Text(_selfieValidated ? 'Retake Selfie' : 'Take Selfie'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selfieValidated ? Colors.white : Colors.green.shade600,
              foregroundColor:
                  _selfieValidated ? Colors.green.shade700 : Colors.white,
              elevation: 0,
              side:
                  _selfieValidated
                      ? BorderSide(color: Colors.green.shade600)
                      : null,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_capturedImages.length > 1)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _capturedImages.length - 1,
            itemBuilder: (context, index) {
              final imgFile = _capturedImages[index + 1];
              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(imgFile, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _capturedImages.removeAt(index + 1);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        if (_capturedImages.length > 1) const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _captureAdditionalImage,
            icon: const Icon(Icons.add_a_photo, size: 20),
            label: const Text('Add Image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green.shade700,
              side: BorderSide(color: Colors.green.shade300, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelMeterSection() {
    return TextField(
      controller: _travelMeterController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Travel Meter',
        hintText: 'e.g. 12500',
        prefixIcon: Icon(Icons.speed, color: Colors.green.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isFormValid ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              elevation: _isFormValid ? 4 : 0,
              shadowColor: Colors.green.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isStartingWork ? 'Start Work' : 'End Work',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isFormValid) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
