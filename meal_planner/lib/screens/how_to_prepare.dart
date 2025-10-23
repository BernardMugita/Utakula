import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/services/food_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class HowToPrepare extends StatefulWidget {
  const HowToPrepare({Key? key}) : super(key: key);

  @override
  State<HowToPrepare> createState() => _HowToPrepareState();
}

class _HowToPrepareState extends State<HowToPrepare> {
  Map<String, dynamic>? selectedPlan;
  FoodApi foods = FoodApi();
  FuncUtils appFuns = FuncUtils();

  // Store instructions for each meal type
  Map<String, String> instructions = {};
  Map<String, bool> isLoading = {};

  bool fetchingInstructions = false;

  Future<void> fetchInstructionsForAllMealTypes() async {
    for (String mealType in ['Breakfast', 'Lunch', 'Supper']) {
      setState(() {
        isLoading[mealType] = true;
        fetchingInstructions = true;
      });

      try {
        Map plan = selectedPlan?['meals'];

        List<dynamic> foodsList =
            List<dynamic>.from(plan[mealType.toLowerCase()]);

        if (foodsList.isNotEmpty) {
          String contents = foodsList
              .map((food) => food['name']) // Assuming each food has a 'name'
              .join(', ');

          // Send the request to get preparation instructions
          final response = await foods.getPreparationInstructions(
            'How do you prepare $contents?',
          );

          final instructionText = response['response']['candidates'][0]
                  ['content']['parts'][0]['text'] ??
              '';

          setState(() {
            instructions[mealType] = instructionText;
            fetchingInstructions = false;
          });
        }
      } catch (e) {
        print('Error fetching instructions: $e');
        setState(() {
          fetchingInstructions = false;
        });
      } finally {
        setState(() {
          isLoading[mealType] = false;
          fetchingInstructions = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    selectedPlan = args?['selectedPlan'] ?? {};

    fetchInstructionsForAllMealTypes();
  }

  @override
  Widget build(BuildContext context) {
    List<String> mealTypes = ['Breakfast', 'Lunch', 'Supper'];
    var meals = selectedPlan?['meals'] ?? {};

    return DefaultTabController(
      length: mealTypes.length,
      child: Scaffold(
        backgroundColor: ThemeUtils.$backgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text("Preparation guide"),
          backgroundColor: ThemeUtils.$backgroundColor,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios),
          ),
          bottom: TabBar(
            labelColor: ThemeUtils.$primaryColor,
            indicatorColor: ThemeUtils.$primaryColor,
            tabs: mealTypes.map((mealType) => Tab(text: mealType)).toList(),
          ),
        ),
        body: fetchingInstructions && isLoading[mealTypes] == true
            ? Lottie.asset(
                "assets/animations/Cooking.json",
                width: 120,
                height: 120,
                repeat: true,
              )
            : TabBarView(
                children: mealTypes.map((mealType) {
                  var mealsForType = meals[mealType.toLowerCase()] ?? [];

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: mealsForType.map<Widget>((singleMeal) {
                            return FutureBuilder<String>(
                              future: FirebaseStorage.instance
                                  .refFromURL(
                                    'gs://mealplanner-86fce.appspot.com/${singleMeal['image_url']}',
                                  )
                                  .getDownloadURL(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Lottie.asset(
                                    "assets/animations/Loading.json",
                                    width: 80,
                                    height: 80,
                                    repeat: true,
                                  );
                                } else if (snapshot.hasError) {
                                  return const Icon(
                                    FluentIcons.food_24_regular,
                                    size: 50,
                                  );
                                } else {
                                  return Align(
                                    widthFactor: 0.5,
                                    child: Image.network(
                                      snapshot.data!,
                                      fit: BoxFit.contain,
                                      height: 120,
                                      width: 120,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        FluentIcons.food_24_regular,
                                        size: 120,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const Gap(20),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ThemeUtils.$secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const Text(
                                  //   "How to prepare",
                                  //   style: TextStyle(
                                  //     fontSize: 20,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: ThemeUtils.$primaryColor,
                                  //   ),
                                  // ),
                                  const Gap(10),
                                  if (isLoading[mealType] == true)
                                    Center(
                                      child: Lottie.asset(
                                        "assets/animations/Cooking.json",
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.5,
                                        repeat: true,
                                      ),
                                    )
                                  else
                                    instructions.isNotEmpty
                                        ? SizedBox(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                1.5,
                                            child: Markdown(
                                              data: instructions[mealType] ??
                                                  "No instructions available.",
                                              styleSheet: MarkdownStyleSheet(
                                                h2: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                p: const TextStyle(
                                                  fontSize: 16,
                                                  height: 1.5,
                                                ),
                                                listBullet: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const Center(
                                            child: Text(
                                                "Instructions not available."),
                                          ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
