import 'package:dio/dio.dart';
import 'package:flutter_application/models/AuthInterceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;

  factory DioClient() {
    return _instance;
  }  

  DioClient._internal() {
    dio = Dio();
    dio.options.baseUrl = '';
    dio.interceptors.add(AuthInterceptor());
  }
}
