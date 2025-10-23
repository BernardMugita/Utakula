import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/meal_plan_widgets/shared_plan_widget.dart';

class MemberMealPlans extends StatefulWidget {
  final List sharedMealPlans;

  const MemberMealPlans({
    Key? key,
    required this.sharedMealPlans,
  }) : super(key: key);

  @override
  State<MemberMealPlans> createState() => _MemberMealPlansState();
}

class _MemberMealPlansState extends State<MemberMealPlans> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: ThemeUtils.$backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeUtils.$backgroundColor,
        elevation: 0,
        title: const Text(
          "Shared Meal Plans",
          style: TextStyle(fontSize: 20, color: ThemeUtils.$primaryColor),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            FluentIcons.arrow_left_24_regular,
            color: ThemeUtils.$primaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(FluentIcons.info_24_regular),
                Gap(10),
                Expanded(
                  child: Text(
                    "Here is a list of meal plans shared with you. "
                    "View details by clicking on a meal plan or make "
                    "it your active meal plan.",
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeUtils.$blacks,
                    ),
                  ),
                )
              ],
            ),
            const Gap(20),
            for (var plan in widget.sharedMealPlans)
              SharedPlanWidget(
                plan: plan,
              )
          ],
        ),
      ),
    );
  }
}
