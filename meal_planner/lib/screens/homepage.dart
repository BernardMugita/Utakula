import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planner/services/meal_plan_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/homepage_widgets/action_items.dart';
import 'package:meal_planner/widgets/homepage_widgets/date_banner.dart';
import 'package:meal_planner/widgets/homepage_widgets/days_widget.dart';
import 'package:meal_planner/widgets/homepage_widgets/no_meal_plan_alert.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map selectedPlan = {};
  bool isFetchingMealPlan = false;
  Map<String, dynamic> myMealPlan = {};
  List sharedMealPlans = [];
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
          myMealPlan = getMealPlanRequest['payload'];
          selectedPlan = _getTodayMealPlan(myMealPlan['meal_plan']);
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

  Future<Map<String, dynamic>> getSharedPlans() async {
    setState(() {
      isFetchingMealPlan = true;
    });

    try {
      String? token = await appFuncs.fetchUserToken();
      final getSharedMealPlanRequest =
          await mealPlan.fetchSharedMealPlans(token: token);

      if (getSharedMealPlanRequest['status'] == "success") {
        setState(() {
          sharedMealPlans = getSharedMealPlanRequest['payload'];
          isFetchingMealPlan = false;
        });
      } else if (getSharedMealPlanRequest['status'] == "error") {
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
    await getSharedPlans();
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
                const Gap(5),
                const SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(FluentIcons.info_24_regular),
                      Gap(5),
                      Text(
                        "Slide to logout",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: ThemeUtils.$primaryColor, fontSize: 12),
                      )
                    ],
                  ),
                ),
                const Gap(10),
                SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 1.8,
                    child: isFetchingMealPlan
                        ? Lottie.asset("assets/animations/Loading.json")
                        : myMealPlan.isEmpty
                            ? const NoMealPlanAlert()
                            : DaysWidget(
                                selectedPlan: selectedPlan,
                                handleSelectPlan: handleSelectPlan,
                                resetPlan: resetPlan,
                                isFetchingMealPlan: isFetchingMealPlan,
                                myMealPlan: myMealPlan['meal_plan'],
                                sharedPlans: sharedMealPlans,
                                message: message)),
                const Gap(30),
                if (!isFetchingMealPlan)
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
