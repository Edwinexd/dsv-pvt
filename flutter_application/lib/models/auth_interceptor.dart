import 'package:dio/dio.dart';
import 'package:flutter_application/models/secure_storage.dart';

class AuthInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? token = await SecureStorage().getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token}';
    }
    handler.next(options);
  }
}