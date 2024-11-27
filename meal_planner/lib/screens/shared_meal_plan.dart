import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class SharedMealPlan extends StatefulWidget {
  final Map plan;

  const SharedMealPlan({Key? key, required this.plan}) : super(key: key);

  @override
  State<SharedMealPlan> createState() => _SharedMealPlanState();
}

class _SharedMealPlanState extends State<SharedMealPlan> {
  late int initialPage;
  String? selectedDay;

  int getInitialPageBasedOnTime() {
    final now = TimeOfDay.now();
    if (now.hour < 11) {
      return 0;
    } else if (now.hour < 14) {
      return 1;
    } else {
      return 2;
    }
  }

  @override
  void initState() {
    super.initState();
    initialPage = getInitialPageBasedOnTime(); // Determine the current meal
    selectedDay = widget.plan['meal_plan'].isNotEmpty
        ? widget.plan['meal_plan'][0]['day'] // Default to the first day
        : null;
  }

  Map<String, dynamic> getMealsForSelectedDay() {
    if (selectedDay == null) return {};
    final selectedDayData = widget.plan['meal_plan']
        .firstWhere((plan) => plan['day'] == selectedDay, orElse: () => null);
    return selectedDayData?['meals'] ?? {};
  }

  @override
  Widget build(BuildContext context) {
    Map plan = widget.plan;
    List mealPlan = plan['meal_plan'];
    // FuncUtils appFuncs = FuncUtils();

    List<String> days = mealPlan.map((plan) => plan['day'] as String).toList();

    List<dynamic> meals =
        mealPlan.map((plan) => plan['meals'] as dynamic).toList();

    double totalCalories = 0;

    for (var meal in meals) {
      for (var foods in meal.values) {
        for (var food in foods) {
          totalCalories += food['calories'];
        }
      }
    }

    return Scaffold(
      backgroundColor: ThemeUtils.$backgroundColor,
      body: SafeArea(
          minimum: const EdgeInsets.all(20),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    FluentIcons.arrow_left_24_regular,
                    color: ThemeUtils.$primaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    FluentIcons.heart_24_regular,
                    color: ThemeUtils.$primaryColor,
                  ),
                ),
              ],
            ),
            const Gap(20),
            const SizedBox(
              width: double.infinity,
              child: Center(
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: ThemeUtils.$primaryColor,
                  child: Icon(FluentIcons.person_24_regular,
                      color: ThemeUtils.$backgroundColor, size: 100),
                ),
              ),
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${plan['owner']}'s Meal Plan",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        color: ThemeUtils.$primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FluentIcons.fire_24_regular,
                          color: ThemeUtils.$accentColor),
                      Text('$totalCalories Kcal',
                          style: TextStyle(
                              fontSize: 16,
                              color: ThemeUtils.$blacks.withOpacity(0.8),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Gap(10),
                  ElevatedButton(
                      onPressed: () {},
                      style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              ThemeUtils.$secondaryColor)),
                      child: const Text(
                        "Make Active Plan",
                        style: TextStyle(color: ThemeUtils.$primaryColor),
                      )),
                  const Gap(5),
                  const SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.info_24_regular),
                        Gap(10),
                        Text("Use this plan as yours")
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Gap(10),
            SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 5, left: 20, right: 20),
                      decoration: const BoxDecoration(
                        color: ThemeUtils.$secondaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: DropdownButton<String>(
                        hint: const Text("Select"),
                        value: selectedDay,
                        dropdownColor: ThemeUtils.$secondaryColor,
                        items: days.map((day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDay = value;
                          });
                        },
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: ThemeUtils.$secondaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            initialPage: initialPage,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: true,
                          ),
                          items:
                              getMealsForSelectedDay().entries.map((mealEntry) {
                            final mealName = mealEntry.key; // e.g., "breakfast"
                            final foods = List<Map<String, dynamic>>.from(
                                mealEntry.value);

                            double calories = 0;

                            for (var food in foods) {
                              calories += food['calories'];
                            }

                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: ThemeUtils.$secondaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: ThemeUtils.$blacks
                                              .withOpacity(0.2))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        mealName.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: foods.map((food) {
                                              return FutureBuilder<String>(
                                                future: FirebaseStorage.instance
                                                    .refFromURL(
                                                      'gs://mealplanner-86fce.appspot.com/${food['image_url']}',
                                                    )
                                                    .getDownloadURL(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Lottie.asset(
                                                        "assets/animations/Loading.json");
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return const Icon(
                                                        FluentIcons
                                                            .food_24_regular,
                                                        size: 50);
                                                  } else {
                                                    return Container(
                                                      width: 100,
                                                      height: 80,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              width: 1 / 2,
                                                              color: ThemeUtils
                                                                  .$blacks
                                                                  .withOpacity(
                                                                      0.2))),
                                                      child: Column(
                                                        children: [
                                                          Image.network(
                                                            snapshot.data!,
                                                            fit: BoxFit.contain,
                                                            height: 50,
                                                            width: 50,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return const Icon(
                                                                FluentIcons
                                                                    .food_24_regular,
                                                                size: 50,
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(
                                                            width: 80,
                                                            child: Text(
                                                              food['name'],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Total Calories:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  FluentIcons.fire_24_regular,
                                                  color:
                                                      ThemeUtils.$accentColor,
                                                ),
                                                Text(calories.toString())
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ))
          ])),
    );
  }
}
