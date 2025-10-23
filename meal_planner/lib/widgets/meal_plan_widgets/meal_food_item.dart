import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:meal_planner/services/food_api.dart';
import 'package:meal_planner/utils/func_utils.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class MealFoodItem extends StatefulWidget {
  final Map food;

  const MealFoodItem({Key? key, required this.food}) : super(key: key);

  @override
  State<MealFoodItem> createState() => _MealFoodItemState();
}

class _MealFoodItemState extends State<MealFoodItem> {
  String imageUrl = '';
  bool isLoading = false;
  FoodApi foods = FoodApi();
  FuncUtils appFuncs = FuncUtils();
  String message = '';

  Future<void> fetchImageUrl() async {
    setState(() {
      isLoading = true;
    });
    String url = await appFuncs.getDownloadUrl(
      '${widget.food['image_url']}',
    );
    setState(() {
      imageUrl = url;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchImageUrl();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return Draggable<Map<String, dynamic>>(
      data: food as Map<String, dynamic>,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(5),
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ThemeUtils.$backgroundColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: ThemeUtils.$backgroundColor,
                child: isLoading
                    ? const Icon(FluentIcons.food_24_regular)
                    : Image.network(
                        imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(FluentIcons.food_24_regular);
                        },
                      ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  food['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 8,
                    color: ThemeUtils.$primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ), 
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 50,
        height: 70,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ThemeUtils.$backgroundColor),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: ThemeUtils.$backgroundColor,
              child: isLoading
                  ? const Icon(FluentIcons.food_24_regular)
                  : Image.network(
                      imageUrl,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(FluentIcons.food_24_regular);
                      },
                    ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                food['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 8,
                  color: ThemeUtils.$primaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
