import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:meal_planner/widgets/app_widgets/dot_loader.dart';
import 'package:meal_planner/widgets/app_widgets/drawer_tab.dart';
import 'package:gap/gap.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 50),
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 40, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ThemeUtils.$secondaryColor,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: MediaQuery.of(context).size.width / 5,
              backgroundColor: ThemeUtils.$backgroundColor,
              child: const Icon(
                FluentIcons.person_24_regular,
                size: 80,
                color: ThemeUtils.$primaryColor,
              ),
            ),
            const Gap(20),
            const DrawerTab(
                icon: Icon(FluentIcons.table_add_24_regular),
                route: '/new_plan',
                tabTitle: 'New meal plan'),
            const DrawerTab(
                icon: Icon(FluentIcons.food_24_regular),
                route: '/foods',
                tabTitle: 'Foods'),
            const DrawerTab(
                icon: Icon(FluentIcons.person_accounts_24_regular),
                route: '/account',
                tabTitle: 'Account'),
            const DrawerTab(
                icon: Icon(FluentIcons.bowl_salad_24_regular),
                route: '/recipes',
                tabTitle: 'Recipies'),
            const DrawerTab(
                icon: Icon(FluentIcons.clock_24_regular),
                route: '/reminders',
                tabTitle: 'Reminders'),
            const DrawerTab(
                icon: Icon(FluentIcons.settings_24_regular),
                route: '/settings',
                tabTitle: 'Settings'),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  _showLogoutPopup();
                },
                style: ButtonStyle(
                    backgroundColor:
                        const WidgetStatePropertyAll(ThemeUtils.$primaryColor),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(FluentIcons.arrow_exit_20_regular,
                        color: ThemeUtils.$secondaryColor),
                    Text(
                      "Logout",
                      style: TextStyle(color: ThemeUtils.$secondaryColor),
                    )
                  ],
                ))
          ],
        ),
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
