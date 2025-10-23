import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/services/calories_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:gap/gap.dart';

class FoodContainer extends StatefulWidget {
  final Map foodDetails;

  const FoodContainer({
    Key? key,
    required this.foodDetails,
  }) : super(key: key);

  @override
  State<FoodContainer> createState() => _FoodContainerState();
}

class _FoodContainerState extends State<FoodContainer> {
  bool isExpanded = false;
  String imageUrl = '';

  FuncUtils appFuncs = FuncUtils();
  bool isLoading = false;
  bool isFetchingCalories = false;
  List allFoodCalories = [];
  Iterable<dynamic> foodCalories = {};
  String message = '';

  Future<void> fetchImageUrl() async {
    setState(() {
      isLoading = true;
    });
    String url = await appFuncs.getDownloadUrl(
      '${widget.foodDetails['image_url']}',
    );
    setState(() {
      imageUrl = url;
      isLoading = false;
    });
  }

  CaloriesApi calories = CaloriesApi();

  /// Fetch foods asynchronously
  Future<void> fetchCaloriesForFood(String name) async {
    setState(() {
      isFetchingCalories = true;
    });

    try {
      final getCaloriesRequest = await calories.getCalorieStats(foodName: name);

      setState(() {
        allFoodCalories = getCaloriesRequest['food_calories'] ?? [];

        foodCalories = allFoodCalories.where((calories) =>
            calories['name'].toString().toLowerCase() == name.toLowerCase());

        if (foodCalories.isEmpty) {
          message = "No calorie data available for this food.";
        }
      });
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    } finally {
      setState(() {
        isFetchingCalories = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchImageUrl(); // Fetch the URL when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.foodDetails;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: ThemeUtils.$secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: ThemeUtils.$backgroundColor,
                child: isLoading
                    ? const Icon(FluentIcons.food_24_regular)
                    : Image.network(
                        imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(FluentIcons.food_24_regular);
                        },
                      ),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  food['name'],
                  style: const TextStyle(
                    color: ThemeUtils.$primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(food['meal_type'].toString().replaceAll('_', ' ')),
            ],
          ),
          const Gap(5),
          const Divider(),
          const Gap(5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Calorie stats:"),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                    // fetchCaloriesForFood(food['name']);
                  },
                  child: Icon(
                    isExpanded
                        ? Icons.arrow_drop_up_sharp
                        : Icons.arrow_drop_down_sharp,
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) buildCalorieDetails(),
        ],
      ),
    );
  }

  Widget buildCalorieDetails() {
    final food = widget.foodDetails;

    // Check if calorie_breakdown exists and is not null
    if (food['calorie_breakdown'] == null) {
      return buildErrorMessage(); // Handle the case where it's null
    }

    final breakdown = food['calorie_breakdown']['breakdown'];

    // Check if breakdown exists and is a list
    if (breakdown == null || !breakdown.isNotEmpty) {
      return buildErrorMessage(); // Handle the case where breakdown is null or empty
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  FaIcon(
                    FluentIcons.fire_24_regular,
                    color: Colors.orange,
                  ),
                  Gap(10),
                  Text("Total calories"),
                ],
              ),
              Text(
                food['calorie_breakdown']['total'] != null
                    ? "${food['calorie_breakdown']['total'].toString()} cal"
                    : "-------",
              ),
            ],
          ),
          const Gap(10),
          const Row(
            children: [
              Text("Stats:"),
            ],
          ),
          const Gap(10),
          // Use the updated condition to check if breakdown is not empty
          if (breakdown.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)), // Rounded corners
              child: Table(
                border: TableBorder.all(color: ThemeUtils.$secondaryColor),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                        color: ThemeUtils.$primaryColor.withOpacity(0.5)),
                    children: const [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Ntr",
                              style: TextStyle(
                                color: ThemeUtils.$secondaryColor,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Amt",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ThemeUtils.$secondaryColor,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Unts",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ThemeUtils.$secondaryColor,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Cal",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ThemeUtils.$secondaryColor,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const Gap(1),
          if (isFetchingCalories)
            buildLoadingIndicator()
          else if (breakdown.isEmpty)
            buildErrorMessage()
          else
            buildNutrientBreakdown(),
        ],
      ),
    );
  }

  Widget buildLoadingIndicator() {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeUtils.$backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Lottie.asset("assets/animations/Loading.json"),
    );
  }

  Widget buildErrorMessage() {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeUtils.$backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        children: [
          FaIcon(
            FluentIcons.error_circle_24_filled,
            color: ThemeUtils.$error,
            size: 50,
          ),
          Text(
            "Sorry, could not load calories. Try again later.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildNutrientBreakdown() {
    final food = widget.foodDetails;
    final breakdown = food['calorie_breakdown']['breakdown'];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: breakdown.length, // Change to use breakdown directly
      itemBuilder: (context, index) {
        // Ensure we are accessing existing nutrients
        final nutrient = breakdown.keys.elementAt(index);
        final data = breakdown[nutrient]; // Access the data directly

        // Check if data is not null and is a Map
        if (data == null || data is! Map) {
          return const SizedBox();
        }

        bool isLastRow = index == breakdown.length - 1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Gap(1),
              if (nutrient.isNotEmpty)
                _buildTableCell(nutrient,
                    isNutrient: true, isBottomLeft: isLastRow),
              const Gap(1),
              if (data['amount'] != null)
                _buildTableCell(data['amount'].toString()),
              const Gap(1),
              if (data['unit'] != null) _buildTableCell(data['unit']),
              const Gap(1),
              if (data['calories'] != null)
                _buildTableCell(data['calories'].toString(),
                    isBottomRight: isLastRow),
              const Gap(1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableCell(String content,
      {bool isNutrient = false,
      bool isBottomLeft = false,
      bool isBottomRight = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: ThemeUtils.$backgroundColor,
          borderRadius: BorderRadius.only(
            bottomLeft: isBottomLeft ? const Radius.circular(10) : Radius.zero,
            bottomRight:
                isBottomRight ? const Radius.circular(10) : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          appFuncs.formatNutrients(content),
          style: const TextStyle(fontSize: 12),
          textAlign: isNutrient ? TextAlign.left : TextAlign.center,
        ),
      ),
    );
  }
}
