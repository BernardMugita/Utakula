import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CaloriesApi {
  Future<Map<String, dynamic>> getCalorieStats(
      {required String foodName}) async {
    List caloriesList = [];
    try {
      DatabaseReference calorieReference =
          FirebaseDatabase.instance.ref('calories');

      DatabaseEvent event = await calorieReference.once();

      if (event.snapshot.value != null) {
        if (event.snapshot.value is List) {
          caloriesList = List.from(event.snapshot.value as List);
        } else {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            caloriesList.add(value);
          });
        }
      }

      return {
        "success": true,
        "food_calories": caloriesList,
      };
    } on FirebaseException catch (e) {
      return {"error": true, "message": e.message};
    }
  }
}
