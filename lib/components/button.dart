import 'package:flutter/material.dart';
import 'package:masar/theme/AppColors.dart';

class Button extends StatelessWidget {
  String text;
  VoidCallback onPressed;
  Button({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        minimumSize: Size(double.infinity, 55),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.onAccent, fontSize: 20),
      ),
    );
  }
}
