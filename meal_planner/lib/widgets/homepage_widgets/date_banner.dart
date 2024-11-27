import 'package:flutter/material.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/services/user_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/app_widgets/dot_loader.dart';

class DateBanner extends StatefulWidget {
  const DateBanner({super.key});

  @override
  State<DateBanner> createState() => _DateBannerState();
}

class _DateBannerState extends State<DateBanner> {
  UserApi user = UserApi();
  FuncUtils appFuncs = FuncUtils();
  Map<String, dynamic> userDetails = {};
  bool isLoading = false;
  String message = '';
  double sliderPosition = 0.0;

  Auth account = Auth();

  bool loggingOut = false;

  Future<void> logOut() async {
    await account.signOut();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.popAndPushNamed(context, '/login');
      }
      setState(() {
        loggingOut = false;
      });
    });
  }

  Future<void> getUserDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await appFuncs.fetchUserToken();
      final getUserRequest = await user.getUserDetails(token: token);

      if (getUserRequest['status'] == "success") {
        setState(() {
          userDetails = getUserRequest['payload'];
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

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeUtils.$primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.$blacks.withOpacity(0.3),
            offset: const Offset(5.0, 5.0),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    sliderPosition += details.delta.dx;
                  });

                  // Trigger logout prompt if slider reaches end
                  if (sliderPosition >
                      MediaQuery.of(context).size.width * 0.6) {
                    _showLogoutPopup();
                    setState(() {
                      sliderPosition = 0.0; // Reset slider
                    });
                  }
                },
                onHorizontalDragEnd: (_) {
                  setState(() {
                    sliderPosition = 0.0; // Reset slider on drag end
                  });
                },
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeUtils.$primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        userDetails['username'] ?? 'Guest',
                        textAlign: TextAlign.right,
                        style:
                            const TextStyle(color: ThemeUtils.$secondaryColor),
                      ),
                    ),
                    Positioned(
                      left: sliderPosition,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ThemeUtils.$secondaryColor,
                          border: Border.all(color: ThemeUtils.$primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Welcome Back!",
                          style: TextStyle(color: ThemeUtils.$primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to update the dialog UI when loggingOut changes
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: loggingOut
                  ? const Text(
                      'Logging out . . .',
                      style: TextStyle(color: ThemeUtils.$primaryColor),
                    )
                  : const Text(
                      'Confirm Logout',
                      style: TextStyle(color: ThemeUtils.$primaryColor),
                    ),
              content: loggingOut
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: DotLoader(
                        radius: 6,
                        numberOfDots: 7,
                      ),
                    )
                  : const Text('Are you sure you want to log out?'),
              actions: loggingOut
                  ? null
                  : [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            loggingOut = true;
                          });

                          await logOut();
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: ThemeUtils.$error),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}
