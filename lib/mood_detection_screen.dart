import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class MoodDetectionScreen extends StatefulWidget {
  const MoodDetectionScreen({super.key});

  @override
  State<MoodDetectionScreen> createState() => _MoodDetectionScreenState();
}

class _MoodDetectionScreenState extends State<MoodDetectionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  String? _error;
  String _currentMood = 'Initializing...';
  double _moodConfidence = 0.0;
  bool _isProcessing = false;
  late final FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: false,
        enableContours: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _error = 'Camera permission denied. Please enable camera access in settings.';
          _isInitializing = false;
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _error = 'No cameras found on this device.';
          _isInitializing = false;
        });
        return;
      }

      // Find front camera
      CameraDescription? frontCamera;
      try {
        frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
      } catch (e) {
        // If no front camera, use first available
        frontCamera = _cameras!.first;
      }

      // Initialize camera controller
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      // Start image stream for face detection
      await _cameraController!.startImageStream(_processCameraImage);

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error initializing camera: $e';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        // Use the first detected face
        final face = faces.first;
        final mood = _detectMood(face);
        final confidence = _calculateConfidence(face);

        if (mounted) {
          setState(() {
            _currentMood = mood;
            _moodConfidence = confidence;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentMood = 'No face detected';
            _moodConfidence = 0.0;
          });
        }
      }
    } catch (e) {
      // Silently ignore processing errors to avoid UI flicker
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      if (rotation == null) return null;
    } else {
      rotation = InputImageRotation.rotation0deg;
    }

    InputImageFormat? format;
    if (Platform.isAndroid) {
      format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null || format != InputImageFormat.nv21) return null;
    } else {
      format = InputImageFormat.bgra8888;
    }

    // Concatenate all planes into a single byte array
    final allBytes = Uint8List.fromList(
      image.planes.expand((plane) => plane.bytes).toList(),
    );

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: allBytes, metadata: metadata);
  }

  String _detectMood(Face face) {
    // ML Kit provides these probabilities (0.0 to 1.0)
    final smilingProb = face.smilingProbability ?? 0.5;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0.5;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.5;
    final eyeOpenProb = (leftEyeOpen + rightEyeOpen) / 2;

    // Define thresholds
    const highSmile = 0.7; // Definitely smiling
    const lowSmile = 0.4; // Slight frown or neutral
    const eyeOpenThreshold = 0.5; // Eyes half-closed or squinting

    if (smilingProb >= highSmile && eyeOpenProb >= eyeOpenThreshold) {
      return 'Happy';
    } else if (smilingProb <= lowSmile && eyeOpenProb >= eyeOpenThreshold) {
      return 'Sad';
    } else if (smilingProb >= highSmile && eyeOpenProb < eyeOpenThreshold) {
      return 'Surprised';
    } else if (smilingProb <= lowSmile && eyeOpenProb < eyeOpenThreshold) {
      return 'Angry';
    } else if (eyeOpenProb < 0.3) {
      return 'Tired';
    } else {
      return 'Neutral';
    }
  }

  double _calculateConfidence(Face face) {
    final smilingProb = face.smilingProbability ?? 0.5;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0.5;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.5;
    final eyeOpenProb = (leftEyeOpen + rightEyeOpen) / 2;

    // Simple confidence calculation based on how extreme the expression is
    final smileConfidence = (smilingProb - 0.5).abs() * 2;
    final eyeConfidence = (eyeOpenProb - 0.5).abs() * 2;

    return (smileConfidence + eyeConfidence) / 2;
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.orange.shade400;
      case 'sad':
        return Colors.blue.shade600;
      case 'angry':
        return Colors.red.shade500;
      case 'surprised':
        return Colors.purple.shade500;
      case 'neutral':
        return Colors.grey.shade600;
      case 'tired':
        return Colors.indigo.shade500;
      case 'no face detected':
        return Colors.grey.shade400;
      default:
        return Colors.blue.shade500;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'surprised':
        return '😲';
      case 'neutral':
        return '😐';
      case 'tired':
        return '😴';
      case 'no face detected':
        return '👤';
      default:
        return '❓';
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade500,
        title: const Text('Mood Detection'),
      ),
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing camera...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initialize,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Upper part - Camera preview (70% of screen)
                    Expanded(
                      flex: 7,
                      child: Container(
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Camera preview
                            _cameraController != null && _cameraController!.value.isInitialized
                                ? CameraPreview(_cameraController!)
                                : const Center(child: Text('Camera not available')),
                            // Recording indicator
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Mood overlay on camera
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Detected Mood: ',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                    Text(
                                      _currentMood,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Lower part - Mood display (30% of screen)
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getMoodColor(_currentMood).withValues(alpha: 0.3),
                              _getMoodColor(_currentMood).withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Mood emoji
                            Text(
                              _getMoodEmoji(_currentMood),
                              style: const TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 12),
                            // Mood label
                            Text(
                              _currentMood,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _getMoodColor(_currentMood),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Confidence indicator
                            if (_currentMood != 'No face detected' && _currentMood != 'Initializing...')
                              Column(
                                children: [
                                  Text(
                                    'Confidence: ${(_moodConfidence * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 200,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _moodConfidence,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _getMoodColor(_currentMood),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      );
    
  }
}
