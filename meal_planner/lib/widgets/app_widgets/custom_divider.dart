import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Divider(
          color: ThemeUtils.$accentColor,
          height: 3,
          thickness: 1,
        ),
        Gap(2),
        Divider(
          color: ThemeUtils.$accentColor,
          height: 3,
          thickness: 1,
        ),
        Gap(2),
        Divider(
          color: ThemeUtils.$accentColor,
          height: 3,
          thickness: 1,
        ),
        Gap(2),
        Divider(
          color: ThemeUtils.$accentColor,
          height: 3,
          thickness: 1,
        ),
        Gap(2),
        Divider(
          color: ThemeUtils.$accentColor,
          height: 3,
          thickness: 1,
        ),
        Gap(2),
        Divider(
          color: ThemeUtils.$accentColor,
          height: 3,
          thickness: 1,
        ),
        Gap(2),
      ],
    );
  }
}
