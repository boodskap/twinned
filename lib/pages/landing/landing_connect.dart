import 'package:flutter/material.dart';
import 'package:twinned/pages/page_build.dart';
import 'package:twinned/widgets/commons/left_side_image_page_list_item.dart';
import 'package:twinned/widgets/commons/paragraph.dart';
import 'package:twinned/widgets/commons/right_side_image_page_list_item.dart';

class LandingConnectPage extends StatelessWidget {
  static const String title = "Unique Value Proposition";
  static const String description =
      "Every business is unique, our technology is heavily customizable to fit your specific industry.";
  static const List<Paragraph> paragraphs = [
    Paragraph(text: 'Plug & Play hardware sensors, actuators, gateway devices'),
    Paragraph(
        text:
            'Remote device management, firmware over the air upgrade, etc...'),
    Paragraph(text: 'Create realtime intelligence out of the data'),
    Paragraph(text: 'Create alarms, events, notifications'),
  ];

  bool top;
  bool left;
  LandingConnectPage({super.key, this.top = false, this.left = false});

  @override
  Widget build(BuildContext context) {
    if (left) {
      return LeftSideImagePageListItem(
        top: top,
        imageUrl: "assets/images/connect.png",
        title: title,
        description: description,
        paragraphs: paragraphs,
        nextPage: BuildPage.name,
      );
    } else {
      return RightSideImagePageListItem(
        top: top,
        imageUrl: "assets/images/connect.png",
        title: title,
        description: description,
        paragraphs: paragraphs,
        nextPage: BuildPage.name,
      );
    }
  }
}
