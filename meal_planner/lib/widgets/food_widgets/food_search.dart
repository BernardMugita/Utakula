import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class FoodSearch extends StatefulWidget {
  final Function(String) handleSearch;

  const FoodSearch({
    Key? key,
    required this.handleSearch,
  }) : super(key: key);

  @override
  State<FoodSearch> createState() => _FoodSearchState();
}

class _FoodSearchState extends State<FoodSearch> {
  TextEditingController searchQuery = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: ThemeUtils.$secondaryColor,
            border: Border.all(color: ThemeUtils.$primaryColor),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged:
                        widget.handleSearch, // Pass the callback directly
                    controller: searchQuery,
                    decoration: const InputDecoration(
                      hintText: "Search foods",
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const Icon(
                  FluentIcons.search_48_regular,
                  color: ThemeUtils.$primaryColor,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
