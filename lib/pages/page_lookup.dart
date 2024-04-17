import 'package:flutter/material.dart';

import 'package:nocode_commons/core/base_state.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/model/twin_model.dart';

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
                  children: [
                    AccordionSection(
                        isOpen: true,
                        headerBackgroundColorOpened: openColor,
                        headerBackgroundColor: closeColor,
                        leftIcon: Icon(
                          Icons.developer_board_rounded,
                          color: UserSession.getIconColor(),
                          size: UserSession.getIconSize(),
                        ),
                        header: Text('Device Library', style: style),
                        content: const SizedBox(
                            height: 250,
                            child: TwinModel(
                              controlType: ComponentType.deviceModel,
                            ))),
                            AccordionSection(
                        isOpen: false,
                        headerBackgroundColorOpened: openColor,
                        headerBackgroundColor: closeColor,
                        leftIcon: Icon(
                          Icons.departure_board_rounded,
                          color: UserSession.getIconColor(),
                          size: UserSession.getIconSize(),
                        ),
                        header: Text('Asset Library', style: style),
                        content: const SizedBox(
                            height: 250,
                            child: TwinModel(
                              controlType: ComponentType.assetModel,
                            ))),
                    AccordionSection(
                        isOpen: false,
                        headerBackgroundColorOpened: openColor,
                        headerBackgroundColor: closeColor,
                        leftIcon: Icon(
                          Icons.memory_rounded,
                          color: UserSession.getIconColor(),
                          size: UserSession.getIconSize(),
                        ),
                        header: Text('Installation Database', style: style),
                        content: const SizedBox(
                            height: 250,
                            child: TwinModel(
                              controlType: ComponentType.device,
                            ))),
                  ],
                );
              }),
        ),
      ],
    );
  }
}
