
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../global_variables.dart';

class CustomTextField extends StatelessWidget {
  final double width;
  final TextEditingController controller;
  final String hintText;
  final String? followingText;

  const CustomTextField({
    required this.width,
    required this.controller,
    required this.hintText,
    this.followingText = "",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      decoration: BoxDecoration(
        color: basicContainerColor2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Row(
          children: [
            SizedBox(
              width: (followingText == "") ? width : width - 20,
              child: TextField(
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
              SizedBox(
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

class snackBar{
  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey.shade800,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showAppleStyleSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50, // Abstand vom unteren Rand
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Füge die Snackbar zum Overlay hinzu
    overlay.insert(overlayEntry);

    // Entferne die Snackbar nach 3 Sekunden
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }

  void showFailureSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50, // Abstand vom unteren Rand
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Füge die Snackbar zum Overlay hinzu
    overlay.insert(overlayEntry);

    // Entferne die Snackbar nach 3 Sekunden
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }



}