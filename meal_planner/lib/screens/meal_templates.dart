import 'package:flutter/material.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class MealTemplates extends StatefulWidget {
  const MealTemplates({super.key});

  @override
  State<MealTemplates> createState() => _MealTemplatesState();
}

class _MealTemplatesState extends State<MealTemplates> {
  @override
  Widget build(BuildContext context) {
    List<String> templateTypes = ['My Templates', 'Meal Plan Templates'];

    return DefaultTabController(
        length: templateTypes.length,
        child: Scaffold(
            backgroundColor: ThemeUtils.$backgroundColor,
            appBar: AppBar(
              elevation: 0,
              title: const Text("Meal Templates"),
              backgroundColor: ThemeUtils.$backgroundColor,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios),
              ),
              bottom: TabBar(
                labelColor: ThemeUtils.$primaryColor,
                indicatorColor: ThemeUtils.$primaryColor,
                tabs: templateTypes
                    .map((template) => Tab(text: template))
                    .toList(),
              ),
            )));
  }
}
