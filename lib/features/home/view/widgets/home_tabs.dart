import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class HomeTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const HomeTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  static const _tabs = ['Feed', 'Events', 'Marketplace'];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.05, w * 0.03, 0, w * 0.02),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTabChanged(i),
            child: Padding(
              padding: EdgeInsets.only(right: w * 0.06),
              child: Text(
                _tabs[i],
                style: GoogleFonts.workSans(
                  fontSize: w * 0.052,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textBlack
                      : const Color(0xFFC4A882),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
