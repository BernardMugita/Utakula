import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:meal_planner/services/food_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/widgets/meal_plan_widgets/meal_food_item.dart';
import 'package:meal_planner/widgets/meal_plan_widgets/meal_item.dart';

class DayMealPlan extends StatefulWidget {
  final String day;
  final Map meals;
  final Function populateMealDays;

  const DayMealPlan(
      {Key? key,
      required this.day,
      required this.meals,
      required this.populateMealDays})
      : super(key: key);

  @override
  State<DayMealPlan> createState() => _DayMealPlanState();
}

class _DayMealPlanState extends State<DayMealPlan> {
  List allFoods = [];
  FoodApi foods = FoodApi();
  FuncUtils appFuncs = FuncUtils();

  Map<String, dynamic> meals = {'breakfast': [], 'lunch': [], 'supper': []};

  bool isLoading = false;
  String message = '';

  Future<void> fetchFoods() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await appFuncs.fetchUserToken();
      final getFoodsRequest = await foods.getFoods(token: token);

      if (getFoodsRequest['status'] == "success") {
        setState(() {
          allFoods = getFoodsRequest['payload'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  @override
  Widget build(BuildContext context) {
    appFuncs.customPrint(widget.meals);
    return Scaffold(
      backgroundColor: ThemeUtils.$backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeUtils.$primaryColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            FluentIcons.arrow_left_24_regular,
            color: ThemeUtils.$secondaryColor,
          ),
        ),
        title: Text(
          "${widget.day} Meal Plan",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: ThemeUtils.$secondaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.info_24_regular),
                        Gap(10),
                        Expanded(
                          child: Text(
                            "Drag and drop a food item on the meal groups. ",
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeUtils.$primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Gap(10),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Save and Continue",
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeUtils.$primaryColor,
                          ),
                        ),
                        const Gap(10),
                        GestureDetector(
                          onTap: () {
                            widget.populateMealDays(meals);
                            Navigator.pop(context);
                          },
                          child: const CircleAvatar(
                            backgroundColor: ThemeUtils.$primaryColor,
                            child: Icon(FluentIcons.save_24_regular,
                                size: 20, color: ThemeUtils.$backgroundColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.height / 1.135,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: ThemeUtils.$secondaryColor),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 1.17,
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    runSpacing: 5,
                                    spacing: 5,
                                    children: [
                                      for (var food in allFoods)
                                        MealFoodItem(food: food)
                                    ],
                                  ),
                                ),
                              )
                            ]),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Container(
                          // height: MediaQuery.of(context).size.height / 1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: meals.entries.map((meal) {
                              return MealItem(
                                mealName: meal.key,
                                day: widget.day,
                                mealValues: widget.meals[meal.key] ?? {},
                                populateMeal: (Map addedMeal) {
                                  setState(() {
                                    meals[meal.key].add(addedMeal);
                                  });
                                },
                                updateDayMeal: (List dayMeal) {
                                  meals[meal.key] = dayMeal;
                                  widget.meals[meal.key] =
                                      dayMeal; // Sync widget.meals
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ))),
    );
  }
}
