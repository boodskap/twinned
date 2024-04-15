import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/widgets/commons/text_headline_secondary.dart';

const Widget divider = Divider(color: Colors.transparent, thickness: 1);

Widget dividerSmall = Container(
  width: 40,
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Color(0xFFA0A0A0),
        width: 1,
      ),
    ),
  ),
);

List<Widget> authorSection(BuildContext context,
    {String? imageUrl, String? name, String? bio}) {
  return [
    divider,
    Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        children: <Widget>[
          if (imageUrl != null)
            Container(
              margin: const EdgeInsets.only(right: 25),
              child: Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Image.asset(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: <Widget>[
                if (name != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextHeadlineSecondary(text: name),
                  ),
                if (bio != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      bio,
                      style: getBodyTextStyle(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    divider,
  ];
}

ButtonStyle? menuButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.transparent,
    textStyle: buttonTextStyle,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16));

typedef OnPressed = void Function();

Widget getToolDivider({double width = 30, double height = 30}) {
  return SizedBox(
    height: height,
    width: width,
  );
}

Widget getToolButton(String tooltip, IconData iconData, OnPressed onPressed,
    {bool selected = false}) {
  return Tooltip(
      message: tooltip,
      child: TextButton(
          onPressed: onPressed,
          child: FaIcon(
            iconData,
            color: selected
                ? UserSession.getSelectedIconColor()
                : UserSession.getIconColor(),
            size: UserSession.getIconSize(),
          )));
}
