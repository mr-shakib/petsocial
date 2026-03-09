import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

const _navIcons = [
  'assets/icons/home.svg',
  'assets/icons/reels.svg',
  null,
  'assets/icons/notification.svg',
  'assets/icons/profile.svg',
];

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Container(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Container(
          height: w * 0.18,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFF0E8E2), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              // Centre "+" button
              if (i == 2) {
                return GestureDetector(
                  onTap: () => onTap(2),
                  child: Container(
                    width: w * 0.14,
                    height: w * 0.10,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(w * 0.09),
                    ),
                    child: Icon(Icons.add, color: AppColors.black, size: w * 0.065),
                  ),
                );
              }

              final isSelected = i == selectedIndex;
              final iconPath = _navIcons[i]!;
              final color = isSelected ? AppColors.primary : const Color(0xFFB0A9A5);

              return GestureDetector(
                onTap: () => onTap(i),
                child: SvgPicture.asset(
                  iconPath,
                  width: w * 0.065,
                  height: w * 0.065,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
