import 'package:flutter/material.dart';

class StoryActionButtons extends StatelessWidget {
  final double w;
  final double h;

  const StoryActionButtons({super.key, required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: w * 0.04,
      bottom: h * 0.12,
      child: Column(
        children: [
          Icon(Icons.pets, color: Colors.white, size: w * 0.065),
          SizedBox(height: w * 0.06),
          Icon(Icons.send_outlined, color: Colors.white, size: w * 0.065),
        ],
      ),
    );
  }
}
