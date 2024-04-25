import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
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
    Widget? image;

    if (null != twinSysInfo && twinSysInfo!.logoImage!.isNotEmpty) {
      image = UserSession()
          .getImage(domainKey, twinSysInfo!.logoImage!, fit: BoxFit.contain);
    }

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
          Row(
            mainAxisAlignment: null != image
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (null != image)
                SizedBox(
                    width: 180,
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: image!,
                    )),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
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
              )
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            color: Colors.black,
          ),
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
        backgroundColor: Colors.white,
      );
    }

    return Scaffold(
      body: buildPage(context),
      backgroundColor: bgColor,
    );
  }
}
