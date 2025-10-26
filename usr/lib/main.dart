import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<XFile> _capturedImages = [];
  List<XFile> _recordedVideos = [];
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImages.add(image);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _startVideoRecording() async {
    try {
      await _initializeControllerFuture;
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopVideoRecording() async {
    try {
      final video = await _controller!.stopVideoRecording();
      setState(() {
        _recordedVideos.add(video);
        _isRecording = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_controller!),
          ),
          if (_capturedImages.isNotEmpty || _recordedVideos.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _capturedImages.length + _recordedVideos.length,
                itemBuilder: (context, index) {
                  if (index < _capturedImages.length) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.file(
                        File(_capturedImages[index].path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  } else {
                    final videoIndex = index - _capturedImages.length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.black,
                        child: const Icon(
                          Icons.video_file,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _takePicture,
            tooltip: 'Take Picture',
            child: const Icon(Icons.camera),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _isRecording ? _stopVideoRecording : _startVideoRecording,
            tooltip: _isRecording ? 'Stop Recording' : 'Start Recording',
            backgroundColor: _isRecording ? Colors.red : null,
            child: Icon(_isRecording ? Icons.stop : Icons.videocam),
          ),
        ],
      ),
    );
  }
}
