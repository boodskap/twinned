import 'package:flutter/material.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned/core/app_logo.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/pages/page_signin.dart';
import 'package:twinned/pages/widgets/page_landing.dart';
import 'package:twinned/widgets/commons/menu_button.dart';
import 'package:twinned/widgets/commons/widgets.dart';

class NocodeMenuBar extends StatelessWidget {
  final String selectedMenu;
  const NocodeMenuBar({super.key, required this.selectedMenu});

  @override
  Widget build(BuildContext context) {
    Widget? image;

    if (null != twinSysInfo && twinSysInfo!.bannerImage!.isNotEmpty) {
      image = UserSession()
          .getImage(domainKey, twinSysInfo!.bannerImage!, fit: BoxFit.cover);
    }

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
          ),
          margin: const EdgeInsets.all(0),
          child: Row(
            children: [
              InkWell(
                hoverColor: const Color.fromARGB(0, 1, 1, 1),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
                child: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: AppLogo(size: 100, textColor: Colors.blue),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    if (null != image) image,
                    if (null == twinSysInfo ||
                        twinSysInfo!.landingPages!.isEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          children: [
                            MenuButton(
                              label: 'HOME',
                              navigateTo: LandingPage.name,
                              selected: selectedMenu == 'HOME',
                            ),
                            MenuButton(
                                label: 'ABOUT',
                                navigateTo: 'about',
                                selected: selectedMenu == 'ABOUT'),
                            MenuButton(
                                label: 'CONTACT US',
                                navigateTo: 'contact',
                                selected: selectedMenu == 'CONTACT US'),
                            if (domainKey.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const SignInPage(),
                                    ),
                                  );
                                },
                                style: menuButtonStyle,
                                child: const Wrap(
                                  children: [
                                    Icon(
                                      Icons.login,
                                      color: Colors.blue,
                                      size: 24.0,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Sign In!",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.blue,
                                        )),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
