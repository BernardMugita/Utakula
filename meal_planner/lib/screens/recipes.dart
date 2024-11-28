import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  TextEditingController foodsController = TextEditingController();
  TextEditingController spicesController = TextEditingController();

  List<String> foods = [];
  List<String> spices = [];

  void _addItem(
      String input, List<String> list, TextEditingController controller) {
    if (input.isNotEmpty && input.endsWith(',')) {
      String item =
          input.substring(0, input.length - 1).trim(); // Remove trailing comma
      if (item.isNotEmpty) {
        setState(() {
          list.add(item);
        });
      }
      controller.clear(); // Clear the text field
    }
  }

  void _removeItem(int index, List<String> list) {
    setState(() {
      list.removeAt(index);
    });
  }

  Widget _buildItemList(List<String> list) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: list
          .asMap()
          .entries
          .map((entry) => Chip(
                label: Text(entry.value),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () => _removeItem(entry.key, list),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeUtils.$backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Custom Recipe"),
        backgroundColor: ThemeUtils.$backgroundColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(FluentIcons.info_24_regular),
                Gap(10),
                Expanded(
                  child: Text(
                      textAlign: TextAlign.left,
                      "'Custom Recipes' allows you to define how you want to prepare your food. "
                      "You give options such as spices, any health conditions and the system will "
                      "generate the most suitable way for you to prepare your meal."),
                )
              ],
            ),
            const Gap(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("What are you cooking?"),
                const Gap(10),
                _buildItemList(foods),
                TextField(
                  controller: foodsController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: ThemeUtils.$secondaryColor,
                    border: OutlineInputBorder(),
                    labelText: "Foods",
                  ),
                  onChanged: (value) => _addItem(value, foods, foodsController),
                ),
                const Gap(5),
                const SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(FluentIcons.info_24_regular),
                      Gap(5),
                      Text(
                        "Add foods you want to cook separated by comma.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: ThemeUtils.$primaryColor, fontSize: 12),
                      )
                    ],
                  ),
                )
              ],
            ),
            const Gap(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("What spices do you have?"),
                const Gap(10),
                _buildItemList(spices),
                TextField(
                  controller: spicesController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: ThemeUtils.$secondaryColor,
                    border: OutlineInputBorder(),
                    labelText: "Spices",
                  ),
                  onChanged: (value) =>
                      _addItem(value, spices, spicesController),
                ),
                const Gap(5),
                const SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(FluentIcons.info_24_regular),
                      Gap(5),
                      Text(
                        "Add spices you want to use separated by comma.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: ThemeUtils.$primaryColor, fontSize: 12),
                      )
                    ],
                  ),
                )
              ],
            ),
            const Gap(20),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Do you have anything specific about how you prepare your meals?"),
                Gap(10),
                TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: ThemeUtils.$secondaryColor,
                        border: OutlineInputBorder(),
                        labelText: "Anything else",
                        alignLabelWithHint: true)),
                Gap(5),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(FluentIcons.info_24_regular),
                      Gap(5),
                      Expanded(
                        child: Text(
                          "Indicate whether you don't eat certain foods, have food allergies, "
                          "or have specific dietary requirements.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: ThemeUtils.$primaryColor, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            const Gap(20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(Colors.white),
                foregroundColor:
                    const WidgetStatePropertyAll(ThemeUtils.$primaryColor),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide.none,
                  ),
                ),
              ),
              onPressed: () {
                // Handle button press
              },
              child: const Text("Get Prep Instructions"),
            )
          ],
        ),
      ),
    );
  }
}
