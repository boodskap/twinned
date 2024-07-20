import 'package:flutter/material.dart';

import 'package:twin_commons/core/base_state.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:twinned/core/user_session.dart';

class TwinnedLookupPage extends StatefulWidget {
  const TwinnedLookupPage({super.key});

  @override
  State<TwinnedLookupPage> createState() => _TwinnedLookupPageState();
}

class _TwinnedLookupPageState extends BaseState<TwinnedLookupPage> {
  static const Color openColor = Colors.blue;
  static const Color closeColor = Colors.blueGrey;

  @override
  void setup() {
    // TODO: implement setup
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.red;
    }
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final style = UserSession.getPropertyTextStyle().copyWith(fontSize: 16);

    return Column(
      children: [
        Flexible(
          child: ListView.builder(
              itemCount: 1,
              itemBuilder: (index, context) {
                return Accordion(
                  contentBorderColor: UserSession.getToolbarColor(),
                  contentBackgroundColor: Colors.white,
                  contentBorderWidth: 1,
                  scaleWhenAnimating: true,
                  openAndCloseAnimation: true,
                  maxOpenSections: 1,
                  headerPadding: const EdgeInsets.symmetric(
                      vertical: 3.5, horizontal: 7.5),
                  sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                  sectionClosingHapticFeedback: SectionHapticFeedback.light,
                  children: [],
                );
              }),
        ),
      ],
    );
  }
}
