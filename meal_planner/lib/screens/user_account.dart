import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/services/user_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/widgets/app_widgets/dot_loader.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  FuncUtils appFuncs = FuncUtils();
  UserApi user = UserApi();

  Map<String, dynamic> userDetails = {};
  bool isLoading = false;
  String message = '';
  bool isDeletingAccount = false;

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

  Future<void> deleteAccount() async {
    setState(() {
      isDeletingAccount = true;
    });

    try {
      String? token = await appFuncs.fetchUserToken();
      final deleteAccountRequest = await user.deleteUserAccount(token: token);

      if (deleteAccountRequest['status'] == "success") {
        setState(() {
          userDetails = deleteAccountRequest['payload'];
          isDeletingAccount = false;
        });
      }
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    } finally {
      setState(() {
        isDeletingAccount = false;
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
    return Scaffold(
        backgroundColor: ThemeUtils.$backgroundColor,
        appBar: AppBar(
          backgroundColor: ThemeUtils.$backgroundColor,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              FluentIcons.arrow_left_24_regular,
              color: ThemeUtils.$primaryColor,
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image:
                                  AssetImage('assets/images/background.png'))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: 5,
                                  backgroundColor: ThemeUtils.$backgroundColor,
                                  color: ThemeUtils.$backgroundColor,
                                ),
                              ),
                              Positioned(
                                  top: 5,
                                  left: 5,
                                  right: 5,
                                  bottom: 5,
                                  child: CircleAvatar(
                                    radius:
                                        MediaQuery.of(context).size.width / 7,
                                    backgroundColor: ThemeUtils.$backgroundColor
                                        .withOpacity(0.8),
                                    child: const Icon(
                                      FluentIcons.person_24_regular,
                                      size: 80,
                                      color: ThemeUtils.$primaryColor,
                                    ),
                                  )),
                              Positioned(
                                  top: -10,
                                  right: -10,
                                  child: GestureDetector(
                                    child: const CircleAvatar(
                                      radius: 25,
                                      backgroundColor: ThemeUtils.$primaryColor,
                                      child: Icon(
                                        FluentIcons.edit_28_regular,
                                        size: 20,
                                        color: ThemeUtils.$secondaryColor,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                          const Gap(10),
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isLoading)
                                  const DotLoader(
                                    radius: 10,
                                    numberOfDots: 7,
                                  )
                                else
                                  Text(
                                    userDetails['username'],
                                    style: const TextStyle(
                                        color: ThemeUtils.$backgroundColor,
                                        fontSize: 24),
                                  ),
                                const Text(
                                  "Last login: 2022-01-01",
                                  style: TextStyle(
                                      color: ThemeUtils.$backgroundColor,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        top: MediaQuery.of(context).size.height / 3.5,
                        left: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          height: MediaQuery.of(context).size.height / 2,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: ThemeUtils.$secondaryColor),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor:
                                        ThemeUtils.$backgroundColor,
                                    child: Icon(
                                      FluentIcons.person_24_filled,
                                      size: 20,
                                    ),
                                  ),
                                  const Gap(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Full name",
                                        style: TextStyle(
                                            color: ThemeUtils.$primaryColor,
                                            fontSize: 12),
                                      ),
                                      if (isLoading)
                                        const DotLoader(
                                          radius: 6,
                                          numberOfDots: 7,
                                        )
                                      else
                                        Text(
                                          userDetails['username'],
                                          style: const TextStyle(
                                              color: ThemeUtils.$blacks,
                                              fontSize: 18),
                                        )
                                    ],
                                  )
                                ],
                              ),
                              const Gap(20),
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor:
                                        ThemeUtils.$backgroundColor,
                                    child: Icon(
                                      FluentIcons.person_24_filled,
                                      size: 20,
                                    ),
                                  ),
                                  const Gap(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Email Address",
                                        style: TextStyle(
                                            color: ThemeUtils.$primaryColor,
                                            fontSize: 12),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: isLoading
                                            ? const DotLoader(
                                                radius: 6,
                                                numberOfDots: 7,
                                              )
                                            : Text(
                                                userDetails['email'],
                                                style: const TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    color: ThemeUtils.$blacks,
                                                    fontSize: 18),
                                              ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const Gap(20),
                              const Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        ThemeUtils.$backgroundColor,
                                    child: Icon(
                                      FluentIcons.person_24_filled,
                                      size: 20,
                                    ),
                                  ),
                                  Gap(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Member Meal Plans",
                                        style: TextStyle(
                                            color: ThemeUtils.$primaryColor,
                                            fontSize: 12),
                                      ),
                                      Text(
                                        "3",
                                        style: TextStyle(
                                            color: ThemeUtils.$blacks,
                                            fontSize: 18),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const Spacer(),
                              const Gap(5),
                              const SizedBox(
                                width: double.infinity,
                                child: Text(
                                  "Danger zone",
                                  style:
                                      TextStyle(color: ThemeUtils.$accentColor),
                                ),
                              ),
                              const Gap(5),
                              const Divider(
                                color: ThemeUtils.$accentColor,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            _showDeletePopup();
                                          },
                                    style: ButtonStyle(
                                        shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)))),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          FluentIcons.delete_24_regular,
                                          color: ThemeUtils.$accentColor,
                                        ),
                                        Gap(10),
                                        Text(
                                          "Delete Account",
                                          style: TextStyle(
                                            color: ThemeUtils.$accentColor,
                                          ),
                                        )
                                      ],
                                    )),
                              )
                            ],
                          ),
                        ))
                  ],
                )
              ],
            )));
  }

  void _showDeletePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to update the dialog UI when isDeletingAccount changes
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: isDeletingAccount
                  ? const Text(
                      'Deleting Account . . .',
                      style: TextStyle(color: ThemeUtils.$primaryColor),
                    )
                  : const Text(
                      'Confirm Delete!',
                      style: TextStyle(color: ThemeUtils.$primaryColor),
                    ),
              content: isDeletingAccount
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: DotLoader(
                        radius: 6,
                        numberOfDots: 7,
                      ),
                    )
                  : const Text(
                      'Are you sure you want to delete your account? This is irreversable'),
              actions: isDeletingAccount
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
                            isDeletingAccount = true;
                          });

                          await deleteAccount();
                        },
                        child: const Text(
                          'Delete',
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
