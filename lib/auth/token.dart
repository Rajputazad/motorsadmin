import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  // static const String _tokenKey = 'token';

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
       await prefs.setString('token', token);

    // await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') as String;
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}