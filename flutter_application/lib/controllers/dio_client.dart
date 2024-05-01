import 'package:dio/dio.dart';
import 'package:flutter_application/controllers/auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;

  factory DioClient() {
    return _instance;
  }  

  DioClient._internal() {
    dio = Dio();
    dio.options.baseUrl = dotenv.env['BACKEND_API_URL']!;
    dio.options.headers = {'Content-Type': 'application/json'};
    dio.interceptors.add(AuthInterceptor());
  }
}