import 'package:flutter/material.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:gap/gap.dart';

class DrawerTab extends StatefulWidget {
  final Icon icon;
  final String route;
  final String tabTitle;

  const DrawerTab({
    Key? key,
    required this.icon,
    required this.route,
    required this.tabTitle,
  }) : super(key: key);

  @override
  State<DrawerTab> createState() => _DrawerTabState();
}

class _DrawerTabState extends State<DrawerTab> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, widget.route);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
            border: Border.all(
              color: ThemeUtils.$backgroundColor,
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(
              widget.icon.icon,
              size: 25,
              color: ThemeUtils.$primaryColor,
            ),
            const Gap(5),
            Text(
              widget.tabTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}
