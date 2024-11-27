import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/services/invitation_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/widgets/app_widgets/dot_loader.dart';

class InviteFriendsFamily extends StatefulWidget {
  final Map mealPlan;

  const InviteFriendsFamily({Key? key, required this.mealPlan})
      : super(key: key);

  @override
  State<InviteFriendsFamily> createState() => _InviteFriendsFamilyState();
}

class _InviteFriendsFamilyState extends State<InviteFriendsFamily> {
  final TextEditingController emailController = TextEditingController();

  FuncUtils appFuncs = FuncUtils();
  InvitationApi invite = InvitationApi();

  List<String> emailAddresses = [];

  Map response = {};

  bool isVerifying = false;
  bool isLoading = false;
  bool validated = false;

  Future<Map<String, dynamic>> validateEmails() async {
    if (emailAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter at least one email address")),
      );
    }

    setState(() {
      isVerifying = true;
    });

    try {
      String? token = await appFuncs.fetchUserToken();
      final verifyEmailsRequest = await invite.verifyEmailAddresses(
          token: token, emailList: emailAddresses);

      if (verifyEmailsRequest['status'] == "success") {
        setState(() {
          response = verifyEmailsRequest['payload'];
          isVerifying = false;
          if (response['invalid_emails'].isEmpty) {
            validated = true;
          }
        });
      }
    } catch (e) {
      setState(() {
        isVerifying = false;
      });
    }

    return {};
  }

  Future<Map<String, dynamic>> sendInvites() async {
    if (response['existing_emails'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("List of emails is empty")),
      );
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? token = await appFuncs.fetchUserToken();

      if (token != null) {
        final sendInvitesRequest = await invite.sendOutInvites(
            token, response['existing_emails'], widget.mealPlan['id']);

        if (sendInvitesRequest['status'] == "success") {
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: ThemeUtils.$primaryColor,
                content: Text(
                  "Invites Sent Successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ThemeUtils.$secondaryColor,
                      fontWeight: FontWeight.bold),
                ),
                duration: Duration(seconds: 3),
              ),
            );
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeUtils.$backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeUtils.$backgroundColor,
        elevation: 0,
        title: const Text(
          "Invite your family/friends",
          style: TextStyle(fontSize: 20, color: ThemeUtils.$primaryColor),
        ),
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
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ThemeUtils.$primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Text(
                    "Add your family/friends to your meal plan using their email addresses. "
                    "Paste their emails below to verify their accounts before proceeding "
                    "to the next step.",
                    style: TextStyle(
                      fontSize: 15,
                      color: ThemeUtils.$secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "List of emails",
                        style:
                            TextStyle(fontSize: 14, color: ThemeUtils.$blacks),
                      ),
                      const Gap(5),
                      const Divider(
                        color: ThemeUtils.$accentColor,
                      ),
                      const Gap(5),
                      const Text(
                        "Valid email addresses will have a green background and check mark."
                        " while invalid ones will have a red background and a cross",
                        style:
                            TextStyle(fontSize: 14, color: ThemeUtils.$blacks),
                      ),
                      const Gap(5),
                      const Divider(
                        color: ThemeUtils.$accentColor,
                      ),
                      const Gap(5),
                      Column(
                        children: [
                          for (var email in emailAddresses)
                            _buildEmailList(email, response)
                        ],
                      ),
                      const Gap(10),
                      if (emailAddresses.isNotEmpty &&
                          !validated &&
                          !isVerifying)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                validateEmails();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: ThemeUtils.$primaryColor, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                foregroundColor: ThemeUtils.$primaryColor,
                                backgroundColor: Colors.transparent,
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Verify Email(s)"),
                                  Gap(5),
                                  Icon(FluentIcons.checkmark_24_regular)
                                ],
                              ),
                            ),
                          ],
                        )
                    ]),
              ),
            )),
            if (isVerifying)
              const DotLoader(radius: 5, numberOfDots: 7)
            else if (!isVerifying &&
                validated &&
                response['invalid_emails'].isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const DotLoader(radius: 5, numberOfDots: 7)
                  else
                    OutlinedButton(
                      onPressed: () {
                        sendInvites();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: ThemeUtils.$primaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: ThemeUtils.$primaryColor,
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Share Meal plan"),
                          Gap(5),
                          Icon(FluentIcons.share_24_regular)
                        ],
                      ),
                    ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        style: const TextStyle(color: ThemeUtils.$blacks),
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: ThemeUtils.$blacks),
                          filled: true,
                          fillColor: ThemeUtils.$secondaryColor,
                          hintText: "Enter valid email",
                          contentPadding: EdgeInsets.only(left: 20, right: 20),
                          // Remove border and make it rounded
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none, // Removes border
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const Gap(5),
                    ElevatedButton(
                      onPressed: () {
                        if (emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Email is required"),
                              duration: Duration(milliseconds: 500),
                            ),
                          );
                        } else if (!emailController.text.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Email is invalid"),
                              duration: Duration(milliseconds: 500),
                            ),
                          );
                        } else {
                          // Check if email already exists
                          if (!emailAddresses.contains(emailController.text)) {
                            emailAddresses.add(emailController.text);
                            setState(() {
                              emailController.clear();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Email added successfully"),
                                duration: Duration(milliseconds: 500),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Email already exists."),
                                duration: Duration(milliseconds: 500),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeUtils.$primaryColor,
                        foregroundColor: ThemeUtils.$secondaryColor,
                        elevation: 0,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(FluentIcons.add_24_regular),
                    )
                  ],
                ),
              )
          ])),
    );
  }

  Widget _buildEmailList(String email, Map response) {
    bool isInvalid = false;
    bool isExisting = false;

    if (response.isNotEmpty) {
      isInvalid = response['invalid_emails'].contains(email);
      isExisting = response['existing_emails'].contains(email);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: ThemeUtils.$secondaryColor,
        border: Border.all(
          color: isInvalid
              ? const Color.fromARGB(255, 255, 0, 0)
              : isExisting
                  ? const Color.fromARGB(255, 51, 255, 0)
                  : isVerifying
                      ? ThemeUtils.$secondaryColor
                      : ThemeUtils.$secondaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              email,
              style: const TextStyle(
                color: ThemeUtils.$blacks,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                emailAddresses.remove(email);
              });
            },
            icon: Icon(FluentIcons.delete_24_regular,
                color: isInvalid
                    ? const Color.fromARGB(255, 255, 0, 0)
                    : isExisting
                        ? const Color.fromARGB(255, 51, 255, 0)
                        : const Color.fromARGB(255, 255, 0, 0)),
          ),
        ],
      ),
    );
  }
}
