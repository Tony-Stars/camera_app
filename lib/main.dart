import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/utils.dart';
import 'package:geolocator/geolocator.dart';

import 'camera_screen.dart';

Future<void> main() async {
  List<CameraDescription> cameras = <CameraDescription>[];

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Geolocator.requestPermission();
    cameras.addAll(await availableCameras());
  } on CameraException catch (e) {
    logCameraException(e);
  }
  runApp(CameraApp(cameras: cameras));
}

class CameraApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const CameraApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(cameras: cameras),
    );
  }
}
