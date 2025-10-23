import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/services/genai_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  TextEditingController foodsController = TextEditingController();
  TextEditingController spicesController = TextEditingController();
  TextEditingController narrativeController = TextEditingController();

  List<String> foods = [];
  List<String> spices = [];

  String customInstructions = "";
  bool generatingRecipe = false;
  bool error = false;
  bool success = false;

  FuncUtils appFuncs = FuncUtils();
  GenaiApi ai = GenaiApi();

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

  Future<Map<String, dynamic>> customRecipe(BuildContext context) async {
    setState(() {
      generatingRecipe = true;
    });

    // Validate input data
    if (foods.isEmpty || spices.isEmpty || narrativeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide foods, spices, and a narrative."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        generatingRecipe = false;
      });
      return {};
    }

    try {
      String? token = await appFuncs.fetchUserToken();
      if (token == null) {
        throw Exception("User token is null or invalid.");
      }

      // Generate the recipe
      final response = await ai.getCustomRecipe(
        token,
        foods,
        spices,
        narrativeController.text,
      );

      // Validate response structure
      if (response['status'] == "success") {
        final candidates = response['payload']['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception("No recipe candidates found in the response.");
        }

        final contentParts = candidates[0]['content']['parts'] as List?;
        if (contentParts == null || contentParts.isEmpty) {
          throw Exception("No content parts found in the recipe candidate.");
        }

        final recipeText = contentParts[0]['text'] ?? '';
        if (recipeText.isEmpty) {
          throw Exception("Generated recipe text is empty.");
        }

        setState(() {
          success = true;
          customInstructions = recipeText;
          generatingRecipe = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Recipe generated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response['status'] == "error") {
        final errorMessage = response['message'] ?? "Unknown error occurred.";
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Error generating recipe: $e");

      setState(() {
        error = true;
        generatingRecipe = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }

    return {};
  }

  void _resetInstructions() {
    setState(() {
      success = false;
      error = false;
      generatingRecipe = false;
      customInstructions = '';
      foods = [];
      spices = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data =
        customInstructions.isNotEmpty ? jsonDecode(customInstructions) : {};
    appFuncs.customPrint(data);

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
        child: generatingRecipe
            ? Container(
                color: ThemeUtils.$secondaryColor,
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 1.3,
                child: Lottie.asset(
                  "assets/animations/Cooking.json",
                  width: 120,
                  height: 120,
                  repeat: true,
                ),
              )
            : success && customInstructions.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Food:",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: ThemeUtils.$primaryColor,
                                    fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                _resetInstructions();
                              },
                              child: const CircleAvatar(
                                backgroundColor: ThemeUtils.$primaryColor,
                                child: Icon(
                                  FluentIcons.rotate_left_24_regular,
                                  color: ThemeUtils.$backgroundColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        const Gap(10),
                        Text(
                            textAlign: TextAlign.start,
                            "${data['recipe']['name']}"),
                        const Gap(10),
                        const Text("Ingredients:",
                            style: TextStyle(
                                fontSize: 18,
                                color: ThemeUtils.$primaryColor,
                                fontWeight: FontWeight.bold)),
                        const Gap(10),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ThemeUtils.$secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data.isNotEmpty &&
                                  data['recipe']['ingredients'] != null)
                                for (var ingredient in data['recipe']
                                    ['ingredients'])
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            FluentIcons
                                                .bubble_multiple_20_regular,
                                            color: ThemeUtils.$primaryColor,
                                          ),
                                          const Gap(10),
                                          Expanded(
                                              child: Text(
                                            ingredient, // Ingredient name
                                            style: const TextStyle(
                                              color: ThemeUtils.$blacks,
                                            ),
                                          )),
                                        ],
                                      ),
                                      const Gap(10)
                                    ],
                                  ),
                            ],
                          ),
                        ),
                        const Gap(10),
                        const Text("Instructions:",
                            style: TextStyle(
                                fontSize: 18,
                                color: ThemeUtils.$primaryColor,
                                fontWeight: FontWeight.bold)),
                        const Gap(10),
                        Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ThemeUtils.$secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var instruction in data['recipe']
                                      ['instructions'])
                                    Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              FluentIcons
                                                  .bubble_multiple_20_regular,
                                              color: ThemeUtils.$primaryColor,
                                            ),
                                            const Gap(10),
                                            Expanded(child: Text(instruction))
                                          ],
                                        ),
                                        const Gap(10)
                                      ],
                                    )
                                ]))
                      ],
                    ),
                  )
                : Column(
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
                            onChanged: (value) =>
                                _addItem(value, foods, foodsController),
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
                                      color: ThemeUtils.$primaryColor,
                                      fontSize: 12),
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
                                      color: ThemeUtils.$primaryColor,
                                      fontSize: 12),
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
                          const Text(
                              "Do you have anything specific about how you prepare your meals?"),
                          const Gap(10),
                          TextField(
                              maxLines: 4,
                              controller: narrativeController,
                              decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: ThemeUtils.$secondaryColor,
                                  border: OutlineInputBorder(),
                                  labelText: "Anything else",
                                  alignLabelWithHint: true)),
                          const Gap(5),
                          const SizedBox(
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
                                        color: ThemeUtils.$primaryColor,
                                        fontSize: 12),
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
                          backgroundColor:
                              const WidgetStatePropertyAll(Colors.white),
                          foregroundColor: const WidgetStatePropertyAll(
                              ThemeUtils.$primaryColor),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide.none,
                            ),
                          ),
                        ),
                        onPressed: () {
                          customRecipe(context);
                        },
                        child: const Text("Get Prep Instructions"),
                      )
                    ],
                  ),
      ),
    );
  }
}
