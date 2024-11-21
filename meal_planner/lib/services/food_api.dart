import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meal_planner/utils/func_utils.dart';

class FoodApi {
  Future<Map<String, dynamic>> getFoods({required String? token}) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request = await http.post(
          Uri.parse("$url/chakula/foods/get_all_foods"),
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

  Future<Map<String, dynamic>> getPreparationInstructions(
      String contents) async {
    String url = FuncUtils.$baseUrl;

    try {
      final request =
          await http.post(Uri.parse("$url/foods/get_prep_instructions"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, dynamic>{
                'contents': contents,
              }));

      if (request.statusCode == 200) {
        return jsonDecode(request.body);
      } else {
        throw Exception('Failed to load preparation instructions');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }
}
