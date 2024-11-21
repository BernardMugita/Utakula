import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FuncUtils {
  static const $baseUrl = "https://utakula.finalyze.app/utakula";

  static const $serverUrl = "https://6791-41-90-173-108.ngrok-free.app/utakula";

  JsonEncoder encoder = const JsonEncoder.withIndent('  ');

  void customPrint(data) {
    return encoder.convert(data).split('/n').forEach((item) => print(item));
  }

  int convertDayToNumber(String day) {
    if (day == "Monday") {
      return 1;
    } else if (day == "Tuesday") {
      return 2;
    } else if (day == "Wednesday") {
      return 3;
    } else if (day == "Thursday") {
      return 4;
    } else if (day == "Friday") {
      return 5;
    } else if (day == "Saturday") {
      return 6;
    } else if (day == "Sunday") {
      return 7;
    }

    return 1;
  }

  String getFullMealName(List<dynamic> meals) {
    if (meals.isEmpty) return '';
    if (meals.length == 1) return meals[0];

    String fullMealName = '';

    for (int i = 0; i < meals.length; i++) {
      if (i == meals.length - 1) {
        // Add '&' before the last item
        fullMealName += '& ${meals[i]}';
      } else if (i == meals.length - 2) {
        // Add the second last item without a comma
        fullMealName += '${meals[i]} ';
      } else {
        // Add commas for all other items
        fullMealName += '${meals[i]}, ';
      }
    }

    return fullMealName.trim(); // Trim any trailing whitespace
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    String? token = storage.getString("token");

    if (token == null) {
      return false;
    } else {
      final decodedToken = JwtDecoder.decode(token);

      if (DateTime(decodedToken['exp']).hour <= 0) {
        return false;
      } else {
        return true;
      }
    }
  }

  Future<String?> fetchUserToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    String? token = storage.getString("token");

    if (token != null) {
      return token;
    }

    return null;
  }

  Future<String> getDownloadUrl(String filePath) async {
    try {
      Reference ref = FirebaseStorage.instance
          .refFromURL('gs://mealplanner-86fce.appspot.com/$filePath');

      print(ref);
      String downloadUrl = await ref.getDownloadURL();
      print('Download URL fetched: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print("Error occurred while fetching the download URL: $e");
      return "";
    }
  }

  String formatNutrients(String nutrient) {
    if (nutrient == "carbohydrate") {
      return "carbs";
    }

    return nutrient;
  }

  bool hasMealPlanChanged(List currentMealPlan, List newMealPlan) {
    customPrint(currentMealPlan);
    customPrint(newMealPlan);
    const areMealPlansSame = DeepCollectionEquality();
    return !areMealPlansSame.equals(currentMealPlan, newMealPlan);
  }
}
