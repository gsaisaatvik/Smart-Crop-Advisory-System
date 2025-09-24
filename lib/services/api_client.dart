import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );

  Future<Response<dynamic>> postDetection({
    required String imagePath,
    String? cropType,
    String? locale,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
      if (cropType != null) 'cropType': cropType,
      if (locale != null) 'locale': locale,
    });
    return _dio.post('/api/detections', data: formData);
  }

  Future<Response<dynamic>> getTreatments({
    required String disease,
    required String cropType,
    String? locale,
  }) async {
    return _dio.get(
      '/api/treatments',
      queryParameters: {
        'disease': disease,
        'cropType': cropType,
        if (locale != null) 'locale': locale,
      },
    );
  }

  Future<Response<dynamic>> tts(String text, {required String locale}) async {
    return _dio.post('/api/tts', data: {'text': text, 'locale': locale});
  }
}

