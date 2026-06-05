import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/services/cloudinary_services.dart';
import 'package:guardian_x/services/fire_store.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _cameraAvailable = false;
  bool _isRecording = false;
  bool _isUploading = false;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndSetupCamera();
  }

  Future<void> _checkPermissionAndSetupCamera() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera/Microphone permission denied")),
        );
      }
      return;
    }

    await _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );

      _initializeControllerFuture = _controller!.initialize();
      _cameraAvailable = true;

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Camera error: $e")));
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _initializeControllerFuture;
      await _controller!.startVideoRecording();

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Recording error: $e")));
      }
    }
  }

  void _startTimer() async {
    while (_isRecording && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && mounted) {
        setState(() => _recordingSeconds++);
      }
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    try {
      final XFile file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isUploading = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Uploading video... ☁️")),
        );
      }

      // ✅ رفع مباشر بدون compute
      final videoUrl = await CloudinaryService().uploadFile(
        File(file.path),
        isVideo: true,
      );

      if (videoUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload failed ❌")),
          );
        }
        setState(() => _isUploading = false);
        return;
      }

      await FirestoreService().saveEvent(
        videoUrl: videoUrl,
        type: "video_event",
      );

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video uploaded successfully ✅")),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: (_controller == null || !_cameraAvailable)
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          _controller!.value.isInitialized) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            CameraPreview(_controller!),

                            // ⏱️ مؤقت التسجيل
                            if (_isRecording)
                              Positioned(
                                top: 50,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.circle,
                                          color: Colors.red, size: 12),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDuration(_recordingSeconds),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // ⏳ مؤشر الرفع
                            if (_isUploading)
                              Container(
                                color: Colors.black45,
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                          color: Colors.white),
                                      SizedBox(height: 12),
                                      Text(
                                        "Uploading...",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed:
                        _isUploading ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUploading
                          ? Colors.grey[600]
                          : _isRecording
                              ? Colors.red[800]
                              : Colors.grey,
                    ),
                    onPressed: _isUploading
                        ? null
                        : _isRecording
                            ? _stopRecordingAndUpload
                            : _startRecording,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isUploading
                              ? Icons.hourglass_top
                              : _isRecording
                                  ? Icons.stop
                                  : Icons.videocam,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(_isUploading
                            ? "Uploading..."
                            : _isRecording
                                ? "Stop"
                                : "Record"),
                      ],
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
}