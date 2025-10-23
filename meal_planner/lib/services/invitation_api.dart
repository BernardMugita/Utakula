import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meal_planner/utils/func_utils.dart';

class InvitationApi {
  Future<Map<String, dynamic>> verifyEmailAddresses(
      {required String? token, required List<String>? emailList}) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request =
          await http.post(Uri.parse("$url/ombi/invite/verify_email_address"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode(<String, dynamic>{'list_of_emails': emailList}));

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

  Future<Map<String, dynamic>> sendOutInvites(
      String token, List<dynamic> emailList, String mealPlanId) async {
    String url = FuncUtils.$serverUrl;

    try {
      final request = await http.post(
          Uri.parse("$url/ombi/invite/send_out_invites"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String, dynamic>{
            'list_of_emails': emailList,
            'meal_plan_id': mealPlanId
          }));

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
