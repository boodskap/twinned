import 'package:flutter/material.dart';
import 'package:nocode_commons/core/constants.dart';

class TextBody extends StatelessWidget {
  final String text;

  const TextBody({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: marginBottom24,
      child: Text(
        text,
        style: getBodyTextStyle(context),
      ),
    );
  }
}
