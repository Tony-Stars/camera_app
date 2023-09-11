import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void logCameraException(CameraException exception) {
  final code = exception.code;
  final description = exception.description;
  // ignore: avoid_print
  print(
    "Error: $code${description == null ? "" : "\nError Message: $description"}",
  );
}

void showInSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

void showCameraException(CameraException e, BuildContext context) {
  logCameraException(e);
  showInSnackBar('Error: ${e.code}\n${e.description}', context);
}
