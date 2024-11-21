import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:meal_planner/screens/day_meal_plan.dart';
import 'package:meal_planner/services/meal_plan_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/widgets/app_widgets/dot_loader.dart';

class NewMealPlan extends StatefulWidget {
  final List<dynamic> userMealPlan;

  const NewMealPlan({Key? key, required this.userMealPlan}) : super(key: key);

  @override
  State<NewMealPlan> createState() => _NewMealPlanState();
}

class _NewMealPlanState extends State<NewMealPlan> {
  List<dynamic> mealPlan = [
    {"day": "Monday", "meals": {}, "total_calories": 0},
    {"day": "Tuesday", "meals": {}, "total_calories": 0},
    {"day": "Wednesday", "meals": {}, "total_calories": 0},
    {"day": "Thursday", "meals": {}, "total_calories": 0},
    {"day": "Friday", "meals": {}, "total_calories": 0},
    {"day": "Saturday", "meals": {}, "total_calories": 0},
    {"day": "Sunday", "meals": {}, "total_calories": 0}
  ];

  String imageUrl = '';
  bool isLoading = false;
  FuncUtils appFuncs = FuncUtils();
  MealPlanApi planReq = MealPlanApi();
  String message = '';

  List<dynamic> currentMealPlan = [];
  List<dynamic> newMealPlan = [];
  bool hasMealPlanChanged = false;

  Future<void> fetchImageUrl(Map food) async {
    setState(() {
      isLoading = true;
    });
    String url = await appFuncs.getDownloadUrl(
      '${food['image_url']}',
    );
    setState(() {
      imageUrl = url;
      isLoading = false;
    });
  }

  void updateMealPlan(String day, Map mealItems, int totalCals) {
    setState(() {
      mealPlan = mealPlan.map((plan) {
        if (plan['day'] == day) {
          return {
            'day': plan['day'],
            'meals': Map<String, dynamic>.from(mealItems),
            'total_calories': totalCals,
          };
        }
        return plan;
      }).toList();

      newMealPlan = deepCopyMealPlan(mealPlan);
    });
  }

  Future<Map<String, dynamic>> createMealPlan() async {
    if (mealPlan.isEmpty) {
      setState(() {
        isLoading = false;
        message = 'Meal plan is empty';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ThemeUtils.$error,
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: ThemeUtils.$blacks, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return {};
    }

    for (var meal in mealPlan) {
      if (meal['meals'].isEmpty) {
        setState(() {
          isLoading = false;
          message =
              "Please finish preparing your meal plan. Missing meals for ${meal['day']}";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeUtils.$error,
              content: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: ThemeUtils.$blacks, fontWeight: FontWeight.bold),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        return {};
      }
    }

    String? token = await appFuncs.fetchUserToken();

    try {
      final mealPlanActionRequest = widget.userMealPlan.isEmpty
          ? await planReq.createNewPlan(token: token, mealPlan: mealPlan)
          : await planReq.editUserMealPlan(token: token, mealPlan: mealPlan);

      appFuncs.customPrint(mealPlanActionRequest);

      if (mealPlanActionRequest['status'] == "success") {
        setState(() {
          message = mealPlanActionRequest['message'];
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeUtils.$primaryColor,
              content: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: ThemeUtils.$secondaryColor,
                    fontWeight: FontWeight.bold),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          message = widget.userMealPlan.isNotEmpty
              ? mealPlanActionRequest['payload']
              : mealPlanActionRequest['payload'] != null
                  ? mealPlanActionRequest['payload'].split(':')[1]
                  : "Error creating meal plan!";
          isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeUtils.$error,
              content: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: ThemeUtils.$blacks, fontWeight: FontWeight.bold),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        message = e.toString();
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ThemeUtils.$error,
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: ThemeUtils.$blacks, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    return {};
  }

  List<dynamic> deepCopyMealPlan(List<dynamic> original) {
    return original
        .map((item) => {
              'day': item['day'],
              'meals': Map<String, dynamic>.from(item['meals']),
              'total_calories': item['total_calories'],
            })
        .toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.userMealPlan.isNotEmpty) {
      mealPlan = deepCopyMealPlan(widget.userMealPlan);
      currentMealPlan = deepCopyMealPlan(widget.userMealPlan);
    } else {
      currentMealPlan = deepCopyMealPlan(mealPlan);
      newMealPlan = deepCopyMealPlan(currentMealPlan);
    }
    newMealPlan = deepCopyMealPlan(mealPlan);
  }

  @override
  Widget build(BuildContext context) {
    appFuncs.customPrint(widget.userMealPlan);
    return Scaffold(
      backgroundColor: ThemeUtils.$backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeUtils.$backgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            hasMealPlanChanged =
                appFuncs.hasMealPlanChanged(currentMealPlan, newMealPlan);
            if (hasMealPlanChanged) {
              _showConfirmPopup();
            } else {
              Navigator.pop(context);
            }
          },
          child: const Icon(
            FluentIcons.arrow_left_24_regular,
            color: ThemeUtils.$primaryColor,
          ),
        ),
        title: Text(
          widget.userMealPlan.isEmpty
              ? "Create new meal plan"
              : "Edit Meal Plan",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: ThemeUtils.$primaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(FluentIcons.info_24_regular),
                const Gap(10),
                Expanded(
                  child: Text(
                    widget.userMealPlan.isEmpty
                        ? "Click on the '+' on a single item to prepare a day's meal plan."
                        : "Select the 'edit' on each day's plan to edit the foods.",
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeUtils.$primaryColor,
                    ),
                  ),
                )
              ],
            ),
            const Gap(20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: ThemeUtils.$secondaryColor,
                  borderRadius: BorderRadius.circular(30)),
              child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.center,
                  children: mealPlan.map((plan) {
                    return Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      // height: 250,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            plan['day'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: ThemeUtils.$primaryColor,
                            ),
                          ),
                          const Gap(10),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Top dashed line
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Dash(
                                  direction: Axis.horizontal,
                                  dashColor: _toggleDashColor(plan),
                                  dashLength: 5,
                                  length: MediaQuery.of(context).size.width / 3,
                                  dashGap: 3,
                                  dashThickness: 1.5,
                                ),
                              ),
                              // Bottom dashed line
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Dash(
                                  direction: Axis.horizontal,
                                  dashColor: _toggleDashColor(plan),
                                  dashLength: 5,
                                  length: MediaQuery.of(context).size.width / 3,
                                  dashGap: 3,
                                  dashThickness: 1.5,
                                ),
                              ),
                              // Left dashed line
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                child: Dash(
                                  direction: Axis.vertical,
                                  dashColor: _toggleDashColor(plan),
                                  dashLength: 5,
                                  length: 190,
                                  dashGap: 3,
                                  dashThickness: 1.5,
                                ),
                              ),
                              // Right dashed line
                              Positioned(
                                top: 0,
                                bottom: 0,
                                right: 0,
                                child: Dash(
                                  direction: Axis.vertical,
                                  dashColor: _toggleDashColor(plan),
                                  dashLength: 5,
                                  length: 190,
                                  dashGap: 3,
                                  dashThickness: 1.5,
                                ),
                              ),
                              // Inner Container
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(5),
                                height: 180,
                                decoration: BoxDecoration(
                                  color: ThemeUtils.$blacks.withOpacity(0.1),
                                ),
                                child: Center(
                                  child: plan['meals'].isEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DayMealPlan(
                                                        day: plan['day'],
                                                        meals: plan['meals'],
                                                        populateMealDays:
                                                            (Map mealItems) {
                                                          updateMealPlan(
                                                              plan['day'],
                                                              mealItems,
                                                              plan[
                                                                  'total_calories']);
                                                        }),
                                              ),
                                            );
                                          },
                                          child: const CircleAvatar(
                                            backgroundColor:
                                                ThemeUtils.$backgroundColor,
                                            child: Icon(
                                              FluentIcons.add_24_regular,
                                              size: 20,
                                              color: ThemeUtils.$primaryColor,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(2),
                                          child: Column(
                                            children: [
                                              Column(
                                                children: plan['meals']
                                                    .entries
                                                    .map<Widget>((entry) {
                                                  return _buildMeals(
                                                      entry.key, entry.value);
                                                }).toList(),
                                              ),
                                              Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: ThemeUtils
                                                          .$secondaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Calories",
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        "${plan['total_calories']} cal",
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      )
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                              if (plan['meals'].isNotEmpty)
                                Positioned(
                                    top: -10,
                                    right: -10,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DayMealPlan(
                                                day: plan['day'],
                                                meals: plan['meals'],
                                                populateMealDays:
                                                    (Map mealItems) {
                                                  updateMealPlan(
                                                      plan['day'],
                                                      mealItems,
                                                      plan['total_calories']);
                                                }),
                                          ),
                                        );
                                      },
                                      child: const CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            ThemeUtils.$backgroundColor,
                                        child: Icon(
                                          FluentIcons.edit_28_regular,
                                          size: 20,
                                        ),
                                      ),
                                    ))
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList()),
            ),
            const Gap(10),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              backgroundColor: const WidgetStatePropertyAll(
                                  ThemeUtils.$secondaryColor)),
                          onPressed: () {},
                          child: const Text(
                            "Save Draft",
                            style: TextStyle(color: ThemeUtils.$primaryColor),
                          ))),
                  const Gap(10),
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            backgroundColor: const WidgetStatePropertyAll(
                                ThemeUtils.$primaryColor)),
                        onPressed: () {
                          createMealPlan();
                        },
                        child: isLoading
                            ? const DotLoader(
                                radius: 10,
                                numberOfDots: 7,
                              )
                            : const Text(
                                "Save Meal Plan",
                                style: TextStyle(
                                    color: ThemeUtils.$secondaryColor),
                              )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMeals(String mealType, List<dynamic> meals) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: ThemeUtils.$secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            mealType,
            style: const TextStyle(fontSize: 12),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: meals.map<Widget>((meal) {
                return FutureBuilder<String>(
                  future: appFuncs.getDownloadUrl(meal['image_url']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 13,
                        backgroundColor: ThemeUtils.$backgroundColor,
                        child: Icon(
                          FluentIcons.food_24_regular,
                          size: 15,
                        ),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const CircleAvatar(
                        radius: 13,
                        backgroundColor: ThemeUtils.$backgroundColor,
                        child: Icon(
                          FluentIcons.food_24_regular,
                          size: 15,
                        ),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 13,
                        backgroundColor: ThemeUtils.$backgroundColor,
                        child: Image.network(
                          snapshot.data!,
                          height: 20,
                          width: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(FluentIcons.food_24_regular);
                          },
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _toggleDashColor(Map plan) {
    if (plan['meals'].isNotEmpty) {
      return const Color(0xFF00BA06);
    } else if (message.startsWith("Please")) {
      return const Color(0xFF8F3131);
    } else {
      return ThemeUtils.$blacks.withOpacity(0.3);
    }
  }

  void _showConfirmPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Close without saving?',
            style: TextStyle(color: ThemeUtils.$primaryColor),
          ),
          content: const Text(
            'You have made changes to your meal plan that will be lost if you close without saving.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                // Reset the meal plan to its default state
                setState(() {
                  mealPlan = [
                    {"day": "Monday", "meals": {}, "total_calories": 0},
                    {"day": "Tuesday", "meals": {}, "total_calories": 0},
                    {"day": "Wednesday", "meals": {}, "total_calories": 0},
                    {"day": "Thursday", "meals": {}, "total_calories": 0},
                    {"day": "Friday", "meals": {}, "total_calories": 0},
                    {"day": "Saturday", "meals": {}, "total_calories": 0},
                    {"day": "Sunday", "meals": {}, "total_calories": 0},
                  ];
                  currentMealPlan = List.from(mealPlan);
                  newMealPlan = List.from(mealPlan);
                });

                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the page
              },
              child: const Text(
                'Discard Changes',
                style: TextStyle(color: ThemeUtils.$error),
              ),
            ),
          ],
        );
      },
    );
  }
}
