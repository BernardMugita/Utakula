import 'package:flutter/material.dart';
import 'package:meal_planner/screens/new_meal_plan.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/homepage_widgets/day_item.dart';

class DaysWidget extends StatefulWidget {
  final Map selectedPlan;
  final bool isFetchingMealPlan;
  final List myMealPlan;
  final String message;
  final Function(Map<String, dynamic>) handleSelectPlan;
  final Function() resetPlan;

  const DaysWidget(
      {Key? key,
      required this.selectedPlan,
      required this.isFetchingMealPlan,
      required this.myMealPlan,
      required this.message,
      required this.handleSelectPlan,
      required this.resetPlan})
      : super(key: key);

  @override
  State<DaysWidget> createState() => _DaysWidgetState();
}

class _DaysWidgetState extends State<DaysWidget> {
  @override
  Widget build(BuildContext context) {
    Map selectedPlan = widget.selectedPlan;
    // final isFetchingMealPlan = widget.isFetchingMealPlan;
    List myMealPlan = widget.myMealPlan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: ThemeUtils.$secondaryColor,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Your meal plan:",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ThemeUtils.$primaryColor,
                      fontSize: 25,
                      decorationColor: ThemeUtils.$primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewMealPlan(
                                  userMealPlan: myMealPlan,
                                )));
                  },
                  child: CircleAvatar(
                    backgroundColor: ThemeUtils.$blacks.withOpacity(0.1),
                    child: const Icon(
                      Icons.edit,
                      color: ThemeUtils.$primaryColor,
                    ),
                  ),
                )
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              runSpacing: 5,
              spacing: 5,
              children: [
                if (selectedPlan.isNotEmpty)
                  DayItem(
                      plan: Map<String, dynamic>.from(
                          selectedPlan), // Safe casting
                      selectedPlan: selectedPlan,
                      resetDefault: widget.resetPlan,
                      handleSelectPlan: widget.handleSelectPlan)
                else
                  for (var plan in myMealPlan)
                    DayItem(
                        plan: Map<String, dynamic>.from(plan), // Safe casting
                        selectedPlan: selectedPlan,
                        resetDefault: widget.resetPlan,
                        handleSelectPlan: widget.handleSelectPlan),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    backgroundColor: ThemeUtils.$blacks.withOpacity(0.1),
                    child: const Icon(
                      Icons.list,
                      color: ThemeUtils.$primaryColor,
                    ),
                  ),
                )
              ]),
            )
          ]),
    );
  }
}
