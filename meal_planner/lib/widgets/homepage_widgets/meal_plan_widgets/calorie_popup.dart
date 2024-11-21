import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/widgets/homepage_widgets/meal_plan_widgets/calorie_maze.dart';

class CaloriePopup extends StatefulWidget {
  final Map selectedPlan;

  const CaloriePopup({
    Key? key,
    required this.selectedPlan,
  }) : super(key: key);

  @override
  State<CaloriePopup> createState() => _CaloriePopupState();
}

class _CaloriePopupState extends State<CaloriePopup> {
  @override
  Widget build(BuildContext context) {
    final selectedPlan = widget.selectedPlan;
    var meals = selectedPlan.isNotEmpty
        ? selectedPlan['meals'] as Map<Object?, Object?>
        : {};

    var sortedMeals = meals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    var sortedMealsMap = Map.fromEntries(sortedMeals);

    List<Map<Object?, Object?>> foods = [];
    for (var mealItems in sortedMealsMap.values) {
      foods.addAll(List<Map<Object?, Object?>>.from(mealItems as List));
    }

    // Calculate the middle index of the list
    final middleIndex = foods.length ~/ 2;

    // Function to determine size based on index
    double _getImageSize(int index) {
      const baseSize = 30.0; // Minimum size for smaller images
      const maxSize = 70.0; // Maximum size for the middle image

      // Calculate a scale factor based on the image's distance from the middle
      final distanceFromCenter = (middleIndex - index).abs();
      final sizeAdjustment =
          (1 - (distanceFromCenter / middleIndex)) * (maxSize - baseSize);
      return baseSize + sizeAdjustment;
    }

    return SizedBox(
      height: MediaQuery.of(context).size.width / 0.85,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < foods.length; i++)
                FutureBuilder<String>(
                  future: FirebaseStorage.instance
                      .refFromURL(
                          'gs://mealplanner-86fce.appspot.com/${foods[i]['image_url']}')
                      .getDownloadURL(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          width: 120, // Fixed width for the loader
                          height: 120, // Fixed height for the loader
                          child: Lottie.asset(
                            "assets/animations/Loading.json",
                            fit: BoxFit.cover, // Adjust the fit if necessary
                            repeat: true, // Ensures the animation keeps looping
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Icon(
                        FluentIcons.food_24_regular,
                        size: 50,
                      );
                    } else if (snapshot.hasData) {
                      return Align(
                        widthFactor: 0.5,
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.contain,
                          height: _getImageSize(i),
                          width: _getImageSize(i),
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              FluentIcons.food_24_regular,
                              size: _getImageSize(i),
                            );
                          },
                        ),
                      );
                    } else {
                      return Container(
                        child: Text("We have a problem!"),
                      ); // Handle case where snapshot has no data
                    }
                  },
                ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: CalorieMaze(meals: sortedMealsMap),
          ),
        ],
      ),
    );
  }
}
