import 'dart:convert';

import 'package:meal_planner/utils/func_utils.dart';
import 'package:http/http.dart' as http;

class GenaiApi {
  Future<Map<String, dynamic>> getCustomRecipe(
      String token, List foodList, List spices, String narrative) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request = await http.post(Uri.parse("$url/ai/genai/custom_recipe"),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'food_list': foodList,
            'spices': spices,
            'narrative': narrative
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
