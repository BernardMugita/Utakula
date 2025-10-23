import 'package:flutter/material.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class NoMealPlanAlert extends StatelessWidget {
  const NoMealPlanAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: ThemeUtils.$secondaryColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(image: AssetImage('assets/images/food_404.png')),
          const Text("You have not created a meal plan yet!"),
          ElevatedButton(
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                  backgroundColor:
                      const WidgetStatePropertyAll(ThemeUtils.$primaryColor)),
              onPressed: () {
                Navigator.pushNamed(context, '/new_plan');
              },
              child: const Text(
                "Get Started",
                style: TextStyle(color: ThemeUtils.$secondaryColor),
              ))
        ],
      ),
    );
  }
}
