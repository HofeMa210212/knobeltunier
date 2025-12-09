
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final double width;
  final TextEditingController controller;
  final String hintText;
  final String? followingText;
  final bool? onlyNumbers;
  final int? maxNumber;

  const CustomTextField({
    required this.width,
    required this.controller,
    required this.hintText,
    this.followingText = "",
    this.onlyNumbers = false,
    this.maxNumber,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.basicContainerColor2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Row(
          children: [
            Container(
              width: (followingText == "") ? width : width - 20,
              child: TextField(
                keyboardType: (onlyNumbers == true) ? TextInputType.number : TextInputType.text,
                inputFormatters: onlyNumbers == true
                    ? [
                  FilteringTextInputFormatter.digitsOnly,
                  if (maxNumber != null) NumberLimitFormatter(maxNumber!)
                ]
                    : [],

                controller: controller,
                style: GoogleFonts.roboto(
                  color: Colors.white60,
                  fontSize: 18,
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.roboto(
                    color: Colors.white38,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                cursorColor: Colors.white70,
              ),
            ),
            if (followingText != "")
              Container(
                width: 20,
                child: Text(
                  followingText!,
                  style: GoogleFonts.roboto(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NumberLimitFormatter extends TextInputFormatter {
  final int maxNumber;

  NumberLimitFormatter(this.maxNumber);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text);
    if (number == null || number > maxNumber) return oldValue; // Maximalwert beachten
    return newValue;
  }
}