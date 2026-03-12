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
      leadingWidth: w * 0.18,
      leading: Padding(
        padding: EdgeInsets.only(left: w * 0.05),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SvgPicture.asset(
            'assets/icons/app_icon.svg',
            width: w * 0.0795,
            height: w * 0.082,
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: [
        _CircleButton(
          w: w,
          child: SvgPicture.asset(
            'assets/icons/search_icon.svg',
            width: w * 0.048,
            height: w * 0.048,
            colorFilter: const ColorFilter.mode(
              AppColors.textDark,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: w * 0.025),
        _CircleButton(
          w: w,
          child: _HamburgerIcon(w: w),
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
      width: w * 0.1,
      height: w * 0.1,
      decoration: const BoxDecoration(
        color: AppColors.iconButtonBg,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}

class _HamburgerIcon extends StatelessWidget {
  final double w;
  const _HamburgerIcon({required this.w});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.textDark;
    const lineH = 2.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: w * 0.046,
          height: lineH,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: w * 0.013),
        Container(
          width: w * 0.028,
          height: lineH,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
