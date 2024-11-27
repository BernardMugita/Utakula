import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/screens/invite_friends_family.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class ActionItem extends StatefulWidget {
  final Map<String, dynamic> myMealPlan;

  const ActionItem({Key? key, required this.myMealPlan}) : super(key: key);

  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(children: [
        if (widget.myMealPlan.isNotEmpty &&
            widget.myMealPlan['meal_plan'].isNotEmpty)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: ThemeUtils.$secondaryColor,
                border: Border.all(),
                borderRadius: BorderRadius.circular(20)),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InviteFriendsFamily(
                                mealPlan: widget.myMealPlan,
                              )));
                },
                style: const ButtonStyle(
                    elevation: WidgetStatePropertyAll(0),
                    backgroundColor:
                        WidgetStatePropertyAll(ThemeUtils.$secondaryColor)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Invite your family/friends",
                        style: TextStyle(
                            fontSize: 14,
                            color: ThemeUtils.$primaryColor,
                            fontWeight: FontWeight.bold)),
                    Gap(20),
                    Icon(
                      FluentIcons.mail_inbox_arrow_up_24_regular,
                      color: ThemeUtils.$primaryColor,
                    )
                  ],
                )),
          ),
        const Gap(10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: ThemeUtils.$secondaryColor,
              border: Border.all(),
              borderRadius: BorderRadius.circular(20)),
          child: ElevatedButton(
              onPressed: () {},
              style: const ButtonStyle(
                  elevation: WidgetStatePropertyAll(0),
                  backgroundColor:
                      WidgetStatePropertyAll(ThemeUtils.$secondaryColor)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Meal Templates",
                      style: TextStyle(
                          fontSize: 14,
                          color: ThemeUtils.$primaryColor,
                          fontWeight: FontWeight.bold)),
                  Gap(20),
                  Icon(
                    FluentIcons.image_24_regular,
                    color: ThemeUtils.$primaryColor,
                  )
                ],
              )),
        )
      ]),
    );
  }
}
