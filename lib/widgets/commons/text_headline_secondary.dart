import 'package:flutter/material.dart';
import 'package:twinned/core/constants.dart';

class TextHeadlineSecondary extends StatelessWidget {
  final String text;

  const TextHeadlineSecondary({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: marginBottom12,
      child: Text(
        text,
        style: getHeadlineSecondaryTextStyle(context),
      ),
    );
  }
}
