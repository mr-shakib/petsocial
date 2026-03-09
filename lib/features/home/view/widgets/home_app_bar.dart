import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: w * 0.2,
      leading: Padding(
        padding: EdgeInsets.only(left: w * 0.05),
        child: SvgPicture.asset(
          'assets/icons/app_icon.svg',
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        _CircleButton(
          w: w,
          child: Icon(Icons.search_rounded, color: AppColors.textBlack, size: w * 0.055),
        ),
        SizedBox(width: w * 0.03),
        _CircleButton(
          w: w,
          child: _TwoLineMenuIcon(w: w),
        ),
        SizedBox(width: w * 0.05),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final double w;
  final Widget child;

  const _CircleButton({required this.w, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w * 0.11,
      height: w * 0.11,
      decoration: const BoxDecoration(
        color: Color(0xFFF0E8E2),
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}

class _TwoLineMenuIcon extends StatelessWidget {
  final double w;
  const _TwoLineMenuIcon({required this.w});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: w * 0.05,
          height: 2.5,
          decoration: BoxDecoration(
            color: AppColors.textBlack,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: w * 0.013),
        Container(
          width: w * 0.03,
          height: 2.5,
          decoration: BoxDecoration(
            color: AppColors.textBlack,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
