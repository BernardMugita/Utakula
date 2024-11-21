import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/firebase_options.dart';
import 'package:meal_planner/screens/foods.dart';
import 'package:meal_planner/screens/homepage.dart';
import 'package:meal_planner/screens/how_to_prepare.dart';
import 'package:meal_planner/screens/invite_friends_family.dart';
import 'package:meal_planner/screens/login.dart';
import 'package:meal_planner/screens/day_meal_plan.dart';
import 'package:meal_planner/screens/new_meal_plan.dart';
import 'package:meal_planner/screens/user_account.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/app_widgets/side_drawer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FuncUtils appFuncs = FuncUtils();

  final bool isLoggedIn = await appFuncs.checkLoginStatus();
  runApp(MyApp(
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Meal Planner',
        theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: isLoggedIn ? '/' : '/login',
        routes: {
          '/': (context) => const MyHomePage(
                title: "",
              ),
          '/login': (context) => const Login(),
          '/foods': (context) => const Foods(),
          '/howto': (context) => const HowToPrepare(),
          '/day_plan': (context) => DayMealPlan(
                day: '',
                meals: const {},
                populateMealDays: () {},
              ),
          '/new_plan': (context) => const NewMealPlan(
                userMealPlan: [],
              ),
          '/invite': (context) => const InviteFriendsFamily(),
          '/account': (context) => const UserAccount(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeUtils.$accentColor.withOpacity(0.1),
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer(); // Now it will work
            },
            child: const Icon(Icons.reorder),
          ),
        ),
      ),
      body: const Homepage(),
      drawer: const SideDrawer(),
    );
  }
}
