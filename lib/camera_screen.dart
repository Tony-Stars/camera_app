import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/upload_service.dart';
import 'package:flutter_camera/utils.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  TextEditingController teController = TextEditingController();
  XFile? imageFile;
  bool enableAudio = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    for (final description in widget.cameras) {
      if (description.lensDirection == CameraLensDirection.back) {
        if (controller != null) {
          controller!.setDescription(description);
        } else {
          _initializeCameraController(description);
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color:
                      controller != null && controller!.value.isRecordingVideo
                          ? Colors.redAccent
                          : Colors.grey,
                  width: 3.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: TextField(
              maxLines: null,
              controller: teController,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Comment"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Photo"),
              onPressed: onTakePictureButtonPress,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    final cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        "Camera not found",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(controller!);
    }
  }

  void onTakePictureButtonPress() async {
    final cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    final file = await takePicture();

    if (!mounted) {
      return;
    }

    setState(() {
      imageFile = file;
    });

    if (file == null) {
      return;
    }

    showInSnackBar('Picture saved to ${file.path}', context);
    UploadService().upload(file, teController.text);
  }

  Future<void> _initializeCameraController(
    final CameraDescription description,
  ) async {
    final CameraController cameraController = CameraController(
      description,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
          "Camera error ${cameraController.value.errorDescription}",
          context,
        );
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      logCameraException(e);
      final description = e.description;
      if (description != null) {
        showInSnackBar(description, context);
      }
    }
  }

  Future<XFile?> takePicture() async {
    final cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: camera not found.', context);
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      showCameraException(e, context);
      return null;
    }
  }
}
