import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class UploadService {
  final _dio = Dio();

  Future<void> upload(final XFile file, final String comment) async {
    final position = await _getPosition();
    final data = FormData.fromMap({
      "comment": comment,
      "latitude": position.latitude,
      "longitude": position.longitude,
      "photo": file,
    });

    final response = await _dio.post(
      "https://flutter-sandbox.free.beeceptor.com/upload_photo/",
      data: data,
      options: Options(
        headers: {"Content-Type": "application/javascript"},
      ),
    );

    print(response);
  }

  Future<Position> _getPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
