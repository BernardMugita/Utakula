import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:meal_planner/widgets/homepage_widgets/meal_plan_widgets/calorie_popup.dart';

class DayItem extends StatefulWidget {
  final Map<String, dynamic> plan;
  final Map selectedPlan;
  final Function(Map<String, dynamic>) handleSelectPlan;
  final Function() resetDefault;

  const DayItem(
      {Key? key,
      required this.plan,
      required this.selectedPlan,
      required this.handleSelectPlan,
      required this.resetDefault})
      : super(key: key);

  @override
  State<DayItem> createState() => _DayItemState();
}

class _DayItemState extends State<DayItem> {
  bool isLoading = false;
  FuncUtils appFuncs = FuncUtils();

  late int initialPage;

  /// Determines the initial page (0 = breakfast, 1 = lunch, 2 = supper) based on the time of day.
  int getInitialPageBasedOnTime() {
    final now = TimeOfDay.now();
    if (now.hour < 11) {
      return 0; // Breakfast
    } else if (now.hour < 14) {
      return 1; // Lunch
    } else {
      return 2; // Supper
    }
  }

  String imageUrl = '';
  Future<String> fetchImageUrl(food) async {
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

    return url;
  }

  bool get toggleIsActive {
    final plan = widget.plan;
    final selectedPlan = widget.selectedPlan;

    const DeepCollectionEquality equality = DeepCollectionEquality();
    return equality.equals(plan, selectedPlan);
  }

  @override
  void initState() {
    super.initState();
    initialPage = getInitialPageBasedOnTime(); // Determine the current meal
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final selectedPlan = widget.selectedPlan;

    // bool toggleIsActive = Map<String, dynamic>.from(selectedPlan) ==
    //     Map<String, dynamic>.from(plan);

    bool isActive =
        appFuncs.convertDayToNumber(plan['day']) == DateTime.now().weekday;

    var meals = selectedPlan.isNotEmpty
        ? selectedPlan['meals'] as Map<Object?, Object?>
        : {};

    var sortedMeals = meals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    var sortedMealsMap = Map.fromEntries(sortedMeals);

    return GestureDetector(
      onTap: () {
        widget.handleSelectPlan(Map<String, dynamic>.from(plan));
      },
      child: Container(
        width: !toggleIsActive
            ? MediaQuery.of(context).size.width / 4
            : double.infinity,
        height: toggleIsActive ? 300 : 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: isActive || toggleIsActive
                ? ThemeUtils.$secondaryColor
                : ThemeUtils.$primaryColor,
            boxShadow: [
              BoxShadow(
                color: ThemeUtils.$blacks.withOpacity(0.3),
                offset: const Offset(
                  5.0,
                  5.0,
                ),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
            borderRadius: BorderRadius.circular(20)),
        child: toggleIsActive
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        plan['day'],
                        style: TextStyle(
                            color: isActive || toggleIsActive
                                ? ThemeUtils.$primaryColor
                                : ThemeUtils.$secondaryColor,
                            fontSize: 22),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.resetDefault();
                        },
                        child: const Icon(
                          Icons.fullscreen_exit,
                          color: ThemeUtils.$primaryColor,
                        ),
                      )
                    ],
                  ),
                  const Gap(10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(border: Border()),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          initialPage: initialPage, // Set based on time of day
                          enableInfiniteScroll:
                              false, // Disable infinite scrolling
                          enlargeCenterPage:
                              true, // Center and enlarge the active page
                        ),
                        items: sortedMealsMap.entries.map<Widget>((mealEntry) {
                          // Safely cast the value to List<Map<String, dynamic>>
                          final List<Map<Object?, Object?>> foods =
                              List<Map<Object?, Object?>>.from(mealEntry.value);

                          // Create a list of meal names for display.
                          final List<dynamic> mealNames =
                              foods.map((food) => food['name']).toList();

                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  color: ThemeUtils.$backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Meal Title (e.g., Breakfast, Lunch, Supper)
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        mealEntry.key.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Display food images with FutureBuilder for URLs.
                                          for (var food in foods)
                                            FutureBuilder<String>(
                                              future: FirebaseStorage.instance
                                                  .refFromURL(
                                                    'gs://mealplanner-86fce.appspot.com/${food['image_url']}',
                                                  )
                                                  .getDownloadURL(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return SizedBox(
                                                    width: 80,
                                                    height: 80,
                                                    child: Lottie.asset(
                                                        fit: BoxFit.cover,
                                                        "assets/animations/Loading.json"),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return const Icon(
                                                    FluentIcons.food_24_regular,
                                                    size: 50,
                                                  );
                                                } else {
                                                  return Align(
                                                    widthFactor: 0.5,
                                                    child: Image.network(
                                                      snapshot.data!,
                                                      fit: BoxFit.contain,
                                                      height: 80,
                                                      width: 80,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Icon(
                                                          FluentIcons
                                                              .food_24_regular,
                                                          size: 50,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        appFuncs.getFullMealName(mealNames),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const Gap(10),
                  SizedBox(
                    width: double.infinity,
                    child: Row(children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                _showMyDialog();
                              },
                              style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  elevation: const WidgetStatePropertyAll(0),
                                  backgroundColor: WidgetStatePropertyAll(
                                      ThemeUtils.$blacks.withOpacity(0.1))),
                              child: const Text("Calorie Stats",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeUtils.$primaryColor,
                                      fontWeight: FontWeight.bold)))),
                      const Gap(10),
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/howto',
                                    arguments: {"selectedPlan": selectedPlan});
                              },
                              style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  elevation: const WidgetStatePropertyAll(0),
                                  backgroundColor: const WidgetStatePropertyAll(
                                      ThemeUtils.$blacks)),
                              child: const Text("Prepare",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeUtils.$secondaryColor,
                                      fontWeight: FontWeight.bold))))
                    ]),
                  )
                ],
              )
            : Center(
                child: Text(
                plan['day'].substring(0, 3),
                style: TextStyle(
                    color: isActive
                        ? ThemeUtils.$primaryColor
                        : ThemeUtils.$secondaryColor,
                    fontSize: 22),
              )),
        // child: ,
      ),
    );
  }

  Future<void> _showMyDialog() async {
    final selectedPlan = widget.selectedPlan;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calorie Stats',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: ThemeUtils.$primaryColor,
              )),
          content: CaloriePopup(selectedPlan: selectedPlan),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    backgroundColor:
                        const WidgetStatePropertyAll(ThemeUtils.$primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close',
                    style: TextStyle(
                      color: ThemeUtils.$secondaryColor,
                    )),
              ),
            ),
          ],
        );
      },
    );
  }
}
