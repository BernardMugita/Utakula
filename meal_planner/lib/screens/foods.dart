import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/services/food_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/food_widgets/food_banner.dart';
import 'package:meal_planner/widgets/food_widgets/food_container.dart';
import 'package:meal_planner/widgets/food_widgets/food_search.dart';
import 'package:gap/gap.dart';

class Foods extends StatefulWidget {
  const Foods({super.key});

  @override
  State<Foods> createState() => _FoodsState();
}

class _FoodsState extends State<Foods> {
  FoodApi foods = FoodApi();
  FuncUtils appFuncs = FuncUtils();

  bool isLoading = false;
  bool resultsFound = true; // Default to true for all foods
  List allFoods = [];
  List<dynamic> searchResults = [];
  String message = '';

  // Fetch foods asynchronously
  Future<void> fetchFoods() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await appFuncs.fetchUserToken();
      final getFoodsRequest = await foods.getFoods(token: token);

      if (getFoodsRequest['status'] == "success") {
        setState(() {
          allFoods = getFoodsRequest['payload'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Search function
  void searchTransactions(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = allFoods;
        resultsFound = true;
      } else {
        searchResults = allFoods
            .where((food) => food['name']
                .toString()
                .toUpperCase()
                .contains(query.toUpperCase()))
            .toList();
        resultsFound = searchResults.isNotEmpty;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeUtils.$backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeUtils.$backgroundColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(FluentIcons.arrow_left_24_regular),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const FoodBanner(),
            const Gap(10),
            FoodSearch(handleSearch: searchTransactions),
            const Gap(20),
            Expanded(
              child: isLoading
                  ? Lottie.asset("assets/animations/Loading.json")
                  : searchResults.isNotEmpty
                      ? ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return FoodContainer(
                              foodDetails: searchResults[index],
                            );
                          },
                        )
                      : allFoods.isNotEmpty
                          ? ListView.builder(
                              itemCount: allFoods.length,
                              itemBuilder: (context, index) {
                                return FoodContainer(
                                  foodDetails: allFoods[index],
                                );
                              },
                            )
                          : buildErrorMessage(),
            ),
          ],
        ),
      ),
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
          Gap(10),
          Text(
            "No results found.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
