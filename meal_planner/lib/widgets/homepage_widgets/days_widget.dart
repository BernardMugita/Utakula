import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/screens/member_meal_plans.dart';
import 'package:meal_planner/screens/new_meal_plan.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/homepage_widgets/day_item.dart';

class DaysWidget extends StatefulWidget {
  final Map selectedPlan;
  final bool isFetchingMealPlan;
  final List myMealPlan;
  final List sharedPlans;
  final String message;
  final Function(Map<String, dynamic>) handleSelectPlan;
  final Function() resetPlan;

  const DaysWidget(
      {Key? key,
      required this.selectedPlan,
      required this.isFetchingMealPlan,
      required this.myMealPlan,
      required this.sharedPlans,
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
    List sharedMealPlans = widget.sharedPlans;

    print(MediaQuery.of(context).size.width);

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (sharedMealPlans.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemberMealPlans(
                                  sharedMealPlans: sharedMealPlans,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                              side: const WidgetStatePropertyAll(
                                  BorderSide(color: ThemeUtils.$primaryColor)),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              padding: const WidgetStatePropertyAll(
                                  EdgeInsets.only(
                                      top: 5, bottom: 5, left: 10, right: 10))),
                          child: Row(
                            children: [
                              const Text(
                                "Member meal Plans",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeUtils.$blacks),
                              ),
                              const Gap(10),
                              CircleAvatar(
                                backgroundColor:
                                    ThemeUtils.$blacks.withOpacity(0.1),
                                child: const Icon(
                                  FluentIcons.food_chicken_leg_24_regular,
                                  size: 16,
                                  color: ThemeUtils.$primaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          child: Text(
                            "Your shared meal plans",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  Column(
                    children: [
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
                      ),
                      const Gap(5),
                      const SizedBox(
                        child: Text(
                          "Edit",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ]),
    );
  }
}
