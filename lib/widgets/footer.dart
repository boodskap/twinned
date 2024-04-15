import 'package:flutter/material.dart';
import 'package:twinned/widgets/commons/text_body.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentYear = DateTime.now().year;
    return Row(
      children: [
        TextBody(
            text: 'Copyright © $currentYear Boodskap Inc, All rights reserved'),
      ],
    );
  }
}