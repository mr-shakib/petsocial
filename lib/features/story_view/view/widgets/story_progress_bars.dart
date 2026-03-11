import 'package:flutter/material.dart';

class StoryProgressBars extends StatelessWidget {
  final int count;
  final int current;
  final Animation<double> animation;
  final double w;
  final double h;

  const StoryProgressBars({
    super.key,
    required this.count,
    required this.current,
    required this.animation,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: h * 0.055,
      left: w * 0.03,
      right: w * 0.03,
      child: Row(
        children: List.generate(
          count,
          (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.006),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: i < current
                    ? _bar(1.0)
                    : i == current
                        ? AnimatedBuilder(
                            animation: animation,
                            builder: (_, __) => _bar(animation.value),
                          )
                        : _bar(0.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bar(double value) => LinearProgressIndicator(
        value: value,
        minHeight: 2.5,
        backgroundColor: Colors.white38,
        color: Colors.white,
      );
}
