import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/screens/shared_meal_plan.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class SharedPlanWidget extends StatefulWidget {
  final Map plan;

  const SharedPlanWidget({Key? key, required this.plan}) : super(key: key);

  @override
  State<SharedPlanWidget> createState() => _SharedPlanWidgetState();
}

class _SharedPlanWidgetState extends State<SharedPlanWidget> {
  @override
  Widget build(BuildContext context) {
    Map plan = widget.plan;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 1.5,
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.only(top: 16, left: 26, right: 16, bottom: 16),
          decoration: BoxDecoration(
              color: ThemeUtils.$secondaryColor,
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SharedMealPlan(
                                    plan: plan,
                                  )));
                    },
                    child: Text("${plan['owner']}'s Plan",
                        style: const TextStyle(
                            fontSize: 14,
                            color: ThemeUtils.$primaryColor,
                            fontWeight: FontWeight.bold)),
                  ),
                  const Row(
                    children: [
                      Icon(FluentIcons.fire_24_regular),
                      Text('13500 Kcal', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Positioned(
          left: -50,
          top: -10,
          bottom: 0,
          child: CircleAvatar(
              backgroundColor: ThemeUtils.$primaryColor,
              radius: 40,
              child: Icon(Icons.person, color: Colors.white)),
        ),
        Positioned(
            right: -50,
            top: 10,
            bottom: 20,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text(
                "Use Plan",
                style: TextStyle(color: ThemeUtils.$primaryColor),
              ),
            ))
      ],
    );
  }
}
