import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meal_planner/services/storage.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  StorageAccess storage = StorageAccess();
  String url = FuncUtils.$serverUrl;

  Future<Map<String, dynamic>> signUp(
      {required String email,
      required String password,
      required String username}) async {
    final response =
        await http.post(Uri.parse("$url/validate/auth/create_account"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              "email": email,
              "username": username,
              "password": password,
            }));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      return responseData as Map<String, dynamic>;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future<Map<String, dynamic>> signIn(
      {required String username, required String password}) async {
    try {
      final response =
          await http.post(Uri.parse("$url/validate/auth/authorize_account"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                "username": username,
                "password": password,
              }));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData as Map<String, dynamic>;
      } else {
        final responseData = jsonDecode(response.body);
        return responseData as Map<String, dynamic>;
      }
    } catch (e) {
      throw Exception('Something went wrong ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    await storage.remove("token");
  }
}
