import 'package:flutter/material.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/widgets/commons/left_side_image_page_list_item.dart';
import 'package:twinned/widgets/commons/paragraph.dart';
import 'package:twinned/widgets/commons/widgets.dart';
import 'package:twinned/widgets/digitaltwin_menu_bar.dart';
import 'package:twinned/widgets/footer.dart';

class BuildPage extends StatelessWidget {
  static const String name = 'build';

  static const String buildTitle = "Drag & Drop Build";
  static const String buildDescription =
      "Create beautiful GUI and deploy to the app stores in a push of a button.";
  static const List<Paragraph> buildParagraphs = [
    Paragraph(
        text:
            'Runs on Android, IOS, MacOS, Windows, Linux & All major browsers'),
    Paragraph(text: 'Integrate with REST apis, thrid party protocols, etc...'),
    Paragraph(text: '100+ customizable widgets'),
    Paragraph(text: 'Download entire project sour code'),
  ];

  const BuildPage({Key? key}) : super(key: key);

  Widget buildPage(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: <Widget>[
                const NocodeMenuBar(
                  selectedMenu: 'BUILD',
                ),
                LeftSideImagePageListItem(
                  imageUrl: "assets/images/build.png",
                  title: buildTitle,
                  description: buildDescription,
                  paragraphs: buildParagraphs,
                ),
                divider,
                const Footer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPage(context),
      backgroundColor: bgColor,
    );
  }
}
