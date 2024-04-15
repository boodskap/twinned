import 'package:flutter/material.dart';
import 'package:twinned/pages/page_build.dart';
import 'package:twinned/widgets/commons/left_side_image_page_list_item.dart';
import 'package:twinned/widgets/commons/paragraph.dart';
import 'package:twinned/widgets/commons/right_side_image_page_list_item.dart';

class LandingPublishPage extends StatelessWidget {
  static const String title = "Go to Market in Historical Speed";
  static const String description =
      'Foster collaboration across teams and departments.';
  static const List<Paragraph> paragraphs = [
    Paragraph(
        text:
            'Our solutions provide a centralized platform for cross-functional communication'),
    Paragraph(
        text: 'Creating a shared understanding of your industrial landscape.'),
    Paragraph(
        text:
            'Unlock your full potential with our digital twinning technology'),
  ];

  bool top;
  bool left;
  LandingPublishPage({super.key, this.top = false, this.left = true});

  @override
  Widget build(BuildContext context) {
    if (left) {
      return LeftSideImagePageListItem(
        top: top,
        imageUrl: "assets/images/publish.png",
        title: title,
        description: description,
        paragraphs: paragraphs,
        nextPage: BuildPage.name,
      );
    } else {
      return RightSideImagePageListItem(
        top: top,
        imageUrl: "assets/images/publish.png",
        title: title,
        description: description,
        paragraphs: paragraphs,
        nextPage: BuildPage.name,
      );
    }
  }
}
