import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:gap/gap.dart';

class MealItem extends StatefulWidget {
  final String mealName;
  final dynamic mealValues;
  final Function populateMeal;
  final String day;
  final Function updateDayMeal;

  const MealItem({
    Key? key,
    required this.mealName,
    required this.day,
    required this.mealValues,
    required this.populateMeal,
    required this.updateDayMeal,
  }) : super(key: key);

  @override
  State<MealItem> createState() => _MealItemState();
}

class _MealItemState extends State<MealItem> {
  List<Map<String, dynamic>> acceptedMealItems = [];
  bool isLoading = false;
  FuncUtils appFuncs = FuncUtils();
  Map mealDayToUpdate = {};

  Future<void> fetchImageUrl(Map food) async {
    setState(() {
      isLoading = true;
    });
    String url = await appFuncs.getDownloadUrl(
      '${food['image_url']}',
    );
    setState(() {
      food['fetched_image_url'] = url;
      food['calories'] = food['calorie_breakdown']['total'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.mealValues.isNotEmpty) {
      for (var meal in widget.mealValues) {
        acceptedMealItems.add(meal);
        widget.updateDayMeal(acceptedMealItems);
        appFuncs.customPrint(meal);
      }
    }
  }

  Widget buildDashedDragTarget() {
    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (detail) {
        fetchImageUrl(detail.data);
        if (!acceptedMealItems.any((item) => item['id'] == detail.data['id'])) {
          setState(() {
            acceptedMealItems.add(detail.data);
          });

          widget.updateDayMeal(acceptedMealItems);
        }
      },
      builder: (BuildContext context, List<Map<String, dynamic>?> acceptedData,
          List<dynamic> rejectedData) {
        return acceptedMealItems.isEmpty
            ? Container(
                padding: const EdgeInsets.all(5),
                width: double.infinity,
                height: 180,
                child: Stack(
                  children: [
                    // Dashed lines
                    if (acceptedMealItems.isEmpty)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Dash(
                          direction: Axis.horizontal,
                          dashColor: ThemeUtils.$blacks.withOpacity(0.3),
                          dashLength: 5,
                          length: MediaQuery.of(context).size.width / 2.25,
                          dashGap: 3,
                          dashThickness: 1,
                        ),
                      ),
                    if (acceptedMealItems.isEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Dash(
                          direction: Axis.horizontal,
                          dashColor: ThemeUtils.$blacks.withOpacity(0.3),
                          dashLength: 5,
                          length: MediaQuery.of(context).size.width / 2.25,
                          dashGap: 3,
                          dashThickness: 1,
                        ),
                      ),
                    if (acceptedMealItems.isEmpty)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        child: Dash(
                          direction: Axis.vertical,
                          dashColor: ThemeUtils.$blacks.withOpacity(0.3),
                          dashLength: 5,
                          length: 170,
                          dashGap: 3,
                          dashThickness: 1,
                        ),
                      ),
                    if (acceptedMealItems.isEmpty)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: Dash(
                          direction: Axis.vertical,
                          dashColor: ThemeUtils.$blacks.withOpacity(0.3),
                          dashLength: 5,
                          length: 170,
                          dashGap: 3,
                          dashThickness: 1,
                        ),
                      ),
                    // Inner Container with Dragged Food Items
                    if (acceptedMealItems.isEmpty)
                      Container(
                          width: double.infinity,
                          height: 170,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: acceptedData.isNotEmpty
                                ? ThemeUtils.$blacks.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: const Center(
                            child: Text(
                              'Drop here.',
                              style: TextStyle(color: ThemeUtils.$blacks),
                            ),
                          ))
                  ],
                ),
              )
            : SizedBox(
                height: 180,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: acceptedMealItems.map((food) {
                      return Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                            color: ThemeUtils.$backgroundColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: ThemeUtils.$backgroundColor,
                              child: isLoading &&
                                      food['fetched_image_url'] == null
                                  ? const Icon(FluentIcons.food_24_regular)
                                  : food['fetched_image_url'] != null
                                      ? Image.network(
                                          food['fetched_image_url'],
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                                FluentIcons.food_24_regular);
                                          },
                                        )
                                      : const Icon(FluentIcons.food_24_regular),
                            ),
                            const Gap(10),
                            SizedBox(
                              width: 50,
                              child: Text(
                                food['name'],
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12,
                                  color: ThemeUtils.$primaryColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Text(
                            //   "${food['calorie_breakdown']['total'].toString()} cal",
                            //   style: const TextStyle(
                            //     fontSize: 12,
                            //     color: ThemeUtils.$primaryColor,
                            //   ),
                            // ),
                            const Gap(5),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  final updatedMealItems = acceptedMealItems;
                                  updatedMealItems.removeWhere((addedFood) =>
                                      addedFood['id'] == food['id']);
                                  acceptedMealItems = updatedMealItems;
                                  appFuncs.customPrint(acceptedMealItems);
                                });
                                widget.updateDayMeal(acceptedMealItems);
                              },
                              child: const Icon(
                                FluentIcons.dismiss_24_regular,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      height: MediaQuery.of(context).size.height / 3.5,
      child: Column(
        children: [
          Text(
            widget.mealName,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeUtils.$primaryColor,
            ),
          ),
          buildDashedDragTarget(),
        ],
      ),
    );
  }
}
