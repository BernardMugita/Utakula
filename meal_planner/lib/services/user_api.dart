import 'dart:convert';

import 'package:meal_planner/utils/func_utils.dart';
import 'package:http/http.dart' as http;

class UserApi {
  Future<Map<String, dynamic>> getUserDetails({required String? token}) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request = await http.post(
          Uri.parse("$url/jamii/users/get_user_by_id"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          });

      if (request.statusCode == 200) {
        final requestData = jsonDecode(request.body);
        return requestData as Map<String, dynamic>;
      } else {
        final requestData = jsonDecode(request.body);
        return requestData as Map<String, dynamic>;
      }
    } catch (e) {
      throw Exception('Something went wrong ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> deleteUserAccount({required String? token}) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request = await http.post(
          Uri.parse("$url/jamii/users/delete_account"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          });

      if (request.statusCode == 200) {
        final requestData = jsonDecode(request.body);
        return requestData as Map<String, dynamic>;
      } else {
        final requestData = jsonDecode(request.body);
        return requestData as Map<String, dynamic>;
      }
    } catch (e) {
      throw Exception('Something went wrong ${e.toString()}');
    }
  }
}
