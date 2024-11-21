import 'dart:convert';

import 'package:meal_planner/utils/func_utils.dart';
import 'package:http/http.dart' as http;

class MealPlanApi {
  Future<Map<String, dynamic>> getMyMealPlan({required String? token}) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request = await http.post(
          Uri.parse("$url/ratiba/meal_plans/get_user_meal_plan"),
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

  Future<Map<String, dynamic>> createNewPlan(
      {required String? token, required List<dynamic> mealPlan}) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request =
          await http.post(Uri.parse("$url/ratiba/meal_plans/add_new_plan"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(<String, dynamic>{'meal_plan': mealPlan}));

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

  Future<Map<String, dynamic>> editUserMealPlan(
      {required String? token, required List<dynamic> mealPlan}) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request =
          await http.post(Uri.parse("$url/ratiba/meal_plans/update_meal_plan"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(<String, dynamic>{'meal_plan': mealPlan}));

      print(request);

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
