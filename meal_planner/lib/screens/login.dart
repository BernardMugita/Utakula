import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/app_widgets/dot_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Auth loginRequest = Auth();

  bool isLoading = false;

  Future<Map> singInToAccount() async {
    setState(() {
      isLoading = true;
    });
    final signInRequest = await loginRequest.signIn(
        username: usernameController.text, password: passwordController.text);

    if (signInRequest['status'] == "success") {
      SharedPreferences storage = await SharedPreferences.getInstance();

      await storage.setString("token", signInRequest['payload']);

      // Show success SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: ThemeUtils.$primaryColor,
            content: Text(
              "Account Authorized. You'll be redirected shortly.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ThemeUtils.$secondaryColor,
                  fontWeight: FontWeight.bold),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Navigate after the SnackBar duration
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.popAndPushNamed(context, '/');
          setState(() {
            isLoading = false;
          });
        }
      });
    } else if (signInRequest['status'] == "error") {
      // Show error SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: ThemeUtils.$error,
            content: Text(
              "Account Authorization Failed: Try again",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ThemeUtils.$blacks, fontWeight: FontWeight.bold),
            ),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }

    return signInRequest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                opacity: 3,
                fit: BoxFit.cover,
                image: AssetImage('assets/images/background.png'))),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Container(
          padding: const EdgeInsets.all(20),
          color: ThemeUtils.$blacks.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: MediaQuery.of(context).size.width / 5,
                backgroundColor: Colors.transparent,
                backgroundImage: const AssetImage(
                  "assets/images/logo-white.png",
                ),
              ),
              const Gap(20),
              const Text(
                "Utakula?!",
                style: TextStyle(
                    fontFamily: 'Diana',
                    fontSize: 30,
                    color: ThemeUtils.$secondaryColor),
              ),
              const Text("Login to continue",
                  style: TextStyle(color: ThemeUtils.$secondaryColor)),
              const Gap(20),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  controller: usernameController,
                  style: const TextStyle(color: ThemeUtils.$secondaryColor),
                  decoration: const InputDecoration(
                      hintStyle: TextStyle(color: ThemeUtils.$secondaryColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ThemeUtils
                                .$secondaryColor), // White bottom border when inactive
                      ),
                      prefixIcon: Icon(
                        Icons.people_outline_sharp,
                        color: ThemeUtils.$secondaryColor,
                      ),
                      hintText: "Enter username or email"),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    color: ThemeUtils.$secondaryColor
                  ),
                  decoration: const InputDecoration(
                      hintStyle: TextStyle(color: ThemeUtils.$secondaryColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ThemeUtils
                                .$secondaryColor), // White bottom border when inactive
                      ),
                      prefixIcon: Icon(
                        Icons.password,
                        color: ThemeUtils.$secondaryColor,
                      ),
                      hintText: "Enter password"),
                ),
              ),
              const Gap(40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    singInToAccount();
                  },
                  style: ButtonStyle(
                      backgroundColor: const WidgetStatePropertyAll(
                          ThemeUtils.$primaryColor),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  child: isLoading
                      ? const DotLoader(
                          radius: 6,
                          numberOfDots: 7,
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(color: ThemeUtils.$secondaryColor),
                        ),
                ),
              ),
              const Gap(10),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Divider(
                    color: ThemeUtils.$primaryColor,
                  ),
                  Positioned(
                    left: 150,
                    right: 150,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 5, left: 10, right: 10),
                      color: const Color.fromARGB(255, 243, 227, 237),
                      child: const Text(
                        "Or",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              const Gap(10),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(color: ThemeUtils.$secondaryColor)),
                    const Gap(5),
                    InkWell(
                      onTap: () {},
                      highlightColor: ThemeUtils.$secondaryColor,
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                            backgroundColor: ThemeUtils.$secondaryColor,
                            color: ThemeUtils.$primaryColor,
                            decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
