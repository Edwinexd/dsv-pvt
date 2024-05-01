import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// https://pub.dev/packages/flutter_secure_storage
class SecureStorage {
  late FlutterSecureStorage storage;

  SecureStorage() {
    storage = const FlutterSecureStorage();
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'USER_TOKEN');
  }

  void setToken(String token) async {
    storage.write(key: 'USER_TOKEN', value: token);
  }


}