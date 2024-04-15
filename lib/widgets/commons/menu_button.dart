import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final String navigateTo;
  late bool? selected;
  MenuButton(
      {super.key,
      required this.label,
      required this.navigateTo,
      this.selected}) {
    selected = selected ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 14;
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, navigateTo),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: (selected!) ? Colors.blueAccent : Colors.white,
        ),
      ),
    );
  }
}
