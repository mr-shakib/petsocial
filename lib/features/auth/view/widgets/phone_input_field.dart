import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/constants/app_colors.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  /// Called with the full E.164 number (e.g. +8801122223333) on every change.
  final ValueChanged<String>? onCompleteNumber;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.onCompleteNumber,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone Number (User Id)',
            style: TextStyle(
              fontSize: w * 0.036,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          SizedBox(height: h * 0.010),
          IntlPhoneField(
            controller: controller,
            initialCountryCode: 'US',
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: w * 0.038, color: AppColors.textGrey),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: '919 136 9851',
              hintStyle: TextStyle(color: AppColors.textBlack, fontSize: w * 0.038),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.04),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.04),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.04),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.022,
              ),
              counterText: '',
            ),
            showDropdownIcon: false,
            dropdownTextStyle: TextStyle(fontSize: w * 0.038, color: AppColors.textGrey),
            flagsButtonPadding: EdgeInsets.only(left: w * 0.03, right: w * 0.01),
            onChanged: (phone) => onCompleteNumber?.call(phone.completeNumber),
          ),
        ],
      ),
    );
  }
}
