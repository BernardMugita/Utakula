import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class DateBanner extends StatelessWidget {
  const DateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEEE d\'th\' MMM y').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: ThemeUtils.$primaryColor,
          borderRadius: BorderRadius.circular(20),
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
          ]),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: ThemeUtils.$primaryColor,
                    border: Border.all(color: ThemeUtils.$secondaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  formattedDate,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: ThemeUtils.$secondaryColor),
                ),
              ),
              Positioned(
                  child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: ThemeUtils.$primaryColor,
                    border: Border.all(color: ThemeUtils.$secondaryColor),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  "Today:",
                  style: TextStyle(color: ThemeUtils.$secondaryColor),
                ),
              ))
            ],
          ),
          // const Gap(15),
          // const Divider(
          //   color: ThemeUtils.$accentColor,
          // ),
          // const Gap(15),
        ],
      ),
    );
  }
}
