import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/services/meal_plan_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/homepage_widgets/action_items.dart';
import 'package:meal_planner/widgets/homepage_widgets/date_banner.dart';
import 'package:meal_planner/widgets/homepage_widgets/days_widget.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map selectedPlan = {};
  bool isFetchingMealPlan = false;
  List<dynamic> myMealPlan = [];
  String message = '';
  String? token = '';

  MealPlanApi mealPlan = MealPlanApi();
  FuncUtils appFuncs = FuncUtils();

  Future<Map<String, dynamic>> getMealPlan() async {
    setState(() {
      isFetchingMealPlan = true;
    });

    try {
      String? token = await appFuncs.fetchUserToken();
      final getMealPlanRequest = await mealPlan.getMyMealPlan(token: token);

      if (getMealPlanRequest['status'] == "success") {
        setState(() {
          myMealPlan = getMealPlanRequest['payload']['meal_plan'];
          selectedPlan = _getTodayMealPlan(myMealPlan);
          isFetchingMealPlan = false;
        });
      } else if (getMealPlanRequest['status'] == "error") {
        setState(() {
          isFetchingMealPlan = false;
        });
      }
    } catch (e) {
      setState(() {
        message = e.toString();
        isFetchingMealPlan = false;
      });
    }

    return {};
  }

  Map _getTodayMealPlan(List<dynamic> mealPlans) {
    final todayIndex = DateTime.now().weekday;
    if (todayIndex - 1 < mealPlans.length) {
      return Map<String, dynamic>.from(mealPlans[todayIndex - 1]);
    }
    return {};
  }

  void handleSelectPlan(Map<String, dynamic> plan) {
    setState(() {
      selectedPlan = plan;
    });
  }

  void resetPlan() {
    setState(() {
      selectedPlan = {};
    });
  }

  Future<void> initializeData() async {
    await getMealPlan();
    token = await appFuncs.fetchUserToken();
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handlePullRefresh,
      child: SafeArea(
          child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: ThemeUtils.$accentColor.withOpacity(0.1),
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const DateBanner(),
                const Gap(30),
                SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 1.8,
                    child: isFetchingMealPlan
                        ? Lottie.asset("assets/animations/Loading.json")
                        : myMealPlan.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: ThemeUtils.$secondaryColor),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Image(
                                        image: AssetImage(
                                            'assets/images/food_404.png')),
                                    const Text(
                                        "You have not created a meal plan yet!"),
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                            backgroundColor:
                                                const WidgetStatePropertyAll(
                                                    ThemeUtils.$primaryColor)),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/new_plan');
                                        },
                                        child: const Text(
                                          "Get Started",
                                          style: TextStyle(
                                              color:
                                                  ThemeUtils.$secondaryColor),
                                        ))
                                  ],
                                ),
                              )
                            : DaysWidget(
                                selectedPlan: selectedPlan,
                                handleSelectPlan: handleSelectPlan,
                                resetPlan: resetPlan,
                                isFetchingMealPlan: isFetchingMealPlan,
                                myMealPlan: myMealPlan,
                                message: message)),
                const Gap(30),
                ActionItem(
                  myMealPlan: myMealPlan,
                )
              ]),
        ),
      )),
    );
  }

  Future<void> _handlePullRefresh() async {
    await getMealPlan();
  }
}
