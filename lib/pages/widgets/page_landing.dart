import 'package:flutter/material.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:twinned/pages/landing/landing_build.dart';
import 'package:twinned/pages/landing/landing_connect.dart';
import 'package:twinned/pages/landing/landing_custom.dart';
import 'package:twinned/pages/landing/landing_publish.dart';
import 'package:twinned/pages/page_signin.dart';
import 'package:twinned/widgets/commons/widgets.dart';
import 'package:twinned/widgets/digitaltwin_menu_bar.dart';
import 'package:twinned/widgets/footer.dart';

class LandingPage extends StatelessWidget {
  static const String name = 'landing';

  const LandingPage({Key? key}) : super(key: key);

  Widget buildPage(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const NocodeMenuBar(
            selectedMenu: 'HOME',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    LandingBuildPage(),
                    divider,
                    LandingConnectPage(),
                    divider,
                    LandingPublishPage(),
                    divider,
                    const Footer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomPage(BuildContext context) {
    List<Widget> children = [];
    bool rightText = true;
    for (var element in twinSysInfo!.landingPages!) {
      children.add(CustomLandingPage(
        landingPage: element,
        textOrientation:
            rightText ? TextOrientation.right : TextOrientation.left,
      ));
      rightText = !rightText;
      children.add(const SizedBox(
        height: 25,
      ));
    }

    return SafeArea(
      child: Column(
        children: [
          const NocodeMenuBar(
            selectedMenu: 'HOME',
          ),
          Container(
            height: 8,
            color: Colors.white,
          ),
          SizedBox(
              //height: 40,
              child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const SignInPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      textStyle: buttonTextStyle,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16)),
                  child: const Wrap(
                    children: [
                      Icon(
                        Icons.login,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Sign In!",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          )),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (null != twinSysInfo && twinSysInfo!.landingPages!.isNotEmpty) {
      return Scaffold(
        body: buildCustomPage(context),
        backgroundColor: bgColor,
      );
    }

    return Scaffold(
      body: buildPage(context),
      backgroundColor: bgColor,
    );
  }
}
