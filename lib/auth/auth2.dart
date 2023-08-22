import 'package:logger/logger.dart';
import 'package:motorsadmin/auth/token.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Auth {}

Future<bool> checkvailid() async {
  final apiurl = dotenv.get('API_URL');
  final logger = Logger();
  try {
    // await TokenManager.removeToken();

    final String? token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      var headers = {
        'Content-Type': 'application/json',
        'authorization': token
      };
      var url = Uri.parse('${apiurl}home');
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        logger.d(response.body);
        return false;
      }
    } else {
      return false;
    }
  } catch (e) {
    logger.d('Error: $e');
    return false;
  }
}
