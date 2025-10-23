import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:meal_planner/utils/theme_utils.dart';

class DotLoader extends StatefulWidget {
  final double radius;
  final int numberOfDots;

  const DotLoader({
    Key? key,
    required this.radius,
    required this.numberOfDots,
  }) : super(key: key);

  @override
  _DotLoaderState createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _dotsCount = 7;

  @override
  void initState() {
    super.initState();
    // Set up the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Total duration for one cycle
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely

    // Set up an animation that loops between 0 and dotsCount
    _animation = Tween<double>(begin: 0, end: (_dotsCount - 1).toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _dotsCount = widget.numberOfDots;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: DotsIndicator(
            dotsCount: _dotsCount,
            position:
                _animation.value.round(), // Use the animated value for position
            decorator: DotsDecorator(
              activeColor: ThemeUtils.$primaryColor, // Active dot color
              size: Size.fromRadius(widget.radius), // Inactive dot size
              activeSize: const Size(12.0, 12.0), // Active dot size
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
