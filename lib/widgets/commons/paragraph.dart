import 'package:flutter/material.dart';
import 'package:nocode_commons/core/constants.dart';

class Paragraph extends StatelessWidget {
  final String text;
  const Paragraph({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: marginBottom8,
      child: Text(
        text,
        style: getBodyTextStyle(context),
      ),
    );
  }
}
