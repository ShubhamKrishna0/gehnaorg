import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/data/models/login.dart';

class LoginApi {
  final Dio dio;

  LoginApi(this.dio);

  Future<Login> login(String email, String password) async {
    try {
      final response = await dio.post(
        'http://3.110.34.172:8080/admin/login',
        data: {
          "email": email,
          "password": password,
        },
      );
      if (response.statusCode == 200) {
        return Login.fromJson(response.data);
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      rethrow;
    }
  }
}
