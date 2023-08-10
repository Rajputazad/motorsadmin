import 'package:dio/dio.dart';
import 'package:motorsadmin/auth/token.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
 String? token = await TokenManager.getToken() as String;

    if (token.isNotEmpty) {
      options.headers['authorization'] = 'Bearer $token';
    } 

    handler.next(options);
  }
}
