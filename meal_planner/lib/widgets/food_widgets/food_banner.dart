import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class FoodBanner extends StatefulWidget {
  const FoodBanner({super.key});

  @override
  State<FoodBanner> createState() => _FoodBannerState();
}

class _FoodBannerState extends State<FoodBanner> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width / 2,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(
                    "assets/images/banner_foods_tp.png",
                  )),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          padding: const EdgeInsets.only(left: 10, right: 10),
        ),
        Positioned(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
                color: ThemeUtils.$primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            padding: const EdgeInsets.all(10),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 0,
          left: 0,
          child: Container(
            width: 100,
            decoration: const BoxDecoration(
              color: ThemeUtils.$primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              // border: Border.all(width: 2, color: ThemeUtils.$backgroundColor),
            ),
            padding: const EdgeInsets.all(10),
            child: const Row(
              children: [
                Icon(
                  FluentIcons.food_24_regular,
                  color: ThemeUtils.$secondaryColor,
                ),
                Text(
                  "Foods",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      // fontFamily: 'Diana',
                      color: ThemeUtils.$secondaryColor,
                      fontSize: 24),
                ),
                Spacer(),
                // TextButton(
                //     onPressed: () {},
                //     child:  Row(
                //       children: [
                //         Icon(
                //           FluentIcons.filter_20_regular,
                //           color: ThemeUtils.$secondaryColor,
                //         ),
                //         Text("Filters",
                //             style: TextStyle(
                //                 // fontFamily: 'Diana',
                //                 color: ThemeUtils.$secondaryColor))
                //       ],
                //     ))
              ],
            ),
          ),
        )
      ],
    );
  }
}
