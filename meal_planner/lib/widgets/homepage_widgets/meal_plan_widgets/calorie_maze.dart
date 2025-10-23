import 'package:flutter/material.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class CalorieMaze extends StatefulWidget {
  final Map<dynamic, dynamic> meals;

  const CalorieMaze({
    Key? key,
    required this.meals,
  }) : super(key: key);

  @override
  State<CalorieMaze> createState() => _CalorieMazeState();
}

class _CalorieMazeState extends State<CalorieMaze> {
  @override
  Widget build(BuildContext context) {
    final meals = widget.meals;
    FuncUtils appFuncs = FuncUtils();

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var mealType in meals.keys)
            Container(
              width: MediaQuery.of(context).size.width / 3,
              height: 170,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ThemeUtils.$backgroundColor,
                border: Border.all(color: ThemeUtils.$secondaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealType.toString(), // Display the meal type
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Calculate total calories for the current meal type
                  Text(
                    '${_calculateTotalCalories(meals[mealType])} cal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeUtils.$primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      appFuncs.getFullMealName(
                        _extractMealNames(meals[mealType]),
                      ), // Display the food names
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          // Display the overall total calories
          Container(
            width: MediaQuery.of(context).size.width / 3,
            height: 170,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeUtils.$backgroundColor,
              border: Border.all(color: ThemeUtils.$secondaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Total Calories",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.$blacks,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_calculateOverallTotalCalories(meals)}',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.$primaryColor,
                      ),
                    ),
                    const Text("cal",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ThemeUtils.$primaryColor,
                        ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate the total calories for a given meal type
  int _calculateTotalCalories(List<dynamic> foods) {
    return foods.fold<int>(
      0,
      (total, food) => total + (food['calories'] as int),
    );
  }

  // New helper method to calculate the overall total calories across all meal types
  int _calculateOverallTotalCalories(Map<dynamic, dynamic> meals) {
    int overallTotal = 0;
    for (var foods in meals.values) {
      overallTotal += _calculateTotalCalories(foods);
    }
    return overallTotal;
  }

  // Helper method to extract food names from a list of foods
  List<String> _extractMealNames(List<dynamic> foods) {
    return foods.map((food) => food['name'].toString()).toList();
  }
}
