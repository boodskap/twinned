import 'package:flutter/material.dart';
import 'package:twinned/pages/page_build.dart';
import 'package:twinned/widgets/commons/left_side_image_page_list_item.dart';
import 'package:twinned/widgets/commons/paragraph.dart';
import 'package:twinned/widgets/commons/right_side_image_page_list_item.dart';

class LandingBuildPage extends StatelessWidget {
  static const String title = "Digital Twinning & Transformation";
  static const String description =
      "\nExperience the transformative impact of simulation and optimization";
  static const List<Paragraph> paragraphs = [
    Paragraph(
        text:
            'Our digital twin serves as a virtual playground for any kind of hardware,'),
    Paragraph(text: 'Allowing you to test scenarios, in record speed'),
    Paragraph(text: 'Identify bottlenecks, and improve quality'),
    Paragraph(text: 'Unlock unprecedented levels of efficiency'),
    Paragraph(
        text:
            '\nWe build digital products that thrive at the intersection of your business goals and needs'),
  ];

  bool top;
  bool left;
  LandingBuildPage({super.key, this.top = false, this.left = true});

  @override
  Widget build(BuildContext context) {
    if (left) {
      return LeftSideImagePageListItem(
        top: top,
        imageUrl: "assets/images/build.png",
        title: title,
        description: description,
        paragraphs: paragraphs,
        nextPage: BuildPage.name,
      );
    } else {
      return RightSideImagePageListItem(
        top: top,
        imageUrl: "assets/images/build.png",
        title: title,
        description: description,
        paragraphs: paragraphs,
        nextPage: BuildPage.name,
      );
    }
  }
}
