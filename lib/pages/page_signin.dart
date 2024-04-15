import 'package:flutter/material.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/pages/landing/landing_build.dart';
import 'package:twinned/pages/landing/landing_connect.dart';
import 'package:twinned/pages/landing/landing_custom.dart';
import 'package:twinned/pages/landing/landing_publish.dart';
import 'package:twinned/pages/login/page_forgot_otp_passowrd.dart';
import 'package:twinned/pages/login/page_forgot_password.dart';
import 'package:twinned/pages/login/page_login.dart';
import 'package:twinned/pages/login/page_reset_password.dart';
import 'package:twinned/pages/login/page_signup.dart';
import 'package:twinned/pages/login/page_verify_otp.dart';
import 'package:twinned/pages/mobilelogin/page_mobile_forgot_otp_passowrd.dart';
import 'package:twinned/pages/mobilelogin/page_mobile_forgot_password.dart';
import 'package:twinned/pages/mobilelogin/page_mobile_login.dart';
import 'package:twinned/pages/mobilelogin/page_mobile_reset_password.dart';
import 'package:twinned/pages/mobilelogin/page_mobile_signup.dart';
import 'package:twinned/pages/mobilelogin/page_mobile_verify_otp.dart';
import 'package:verification_api/api/verification.swagger.dart';

class NavigationControl extends StatefulWidget {
  const NavigationControl({
    super.key,
    required Null Function() onCreateAccountPressed,
  });

  @override
  State<NavigationControl> createState() => _NavigationControlState();
}

class _NavigationControlState extends State<NavigationControl> {
  late PageController _pageController;
  RegistrationRes? registrationRes;

  final eFormKey = GlobalKey<FormState>();
  final pFormKey = GlobalKey<FormState>();

  get userId => "defaultUserId";
  get pinToken => "defaultPinToken";
  get pin => "defaultPin";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                LoginPage(pageController: _pageController),
                VerifyOtpPage(
                  pageController: _pageController,
                  registrationRes: registrationRes,
                ),
                ResetPasswordpage(
                  userId: userId,
                  pinToken: pinToken,
                  pin: pin,
                  pageController: _pageController,
                ),
                SignUpPage(pageController: _pageController),
                ForgotPasswordPage(pageController: _pageController),
                ForgotOtpPage(
                  pageController: _pageController,
                  userId: userId,
                  pinToken: pinToken,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationControlMobile extends StatefulWidget {
  const NavigationControlMobile({
    super.key,
    required Null Function() onCreateAccountPressed,
  });

  @override
  State<NavigationControlMobile> createState() =>
      _NavigationControlMobileState();
}

class _NavigationControlMobileState extends State<NavigationControlMobile> {
  late PageController _pageController;
  RegistrationRes? registrationRes;

  final eFormKey = GlobalKey<FormState>();
  final pFormKey = GlobalKey<FormState>();

  get userId => "defaultUserId";
  get pinToken => "defaultPinToken";
  get pin => "defaultPin";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                LoginMobilePage(pageController: _pageController),
                VerifyOtpMobilePage(
                  pageController: _pageController,
                  registrationRes: registrationRes,
                ),
                ResetPasswordMobilepage(
                  userId: userId,
                  pinToken: pinToken,
                  pin: pin,
                  pageController: _pageController,
                ),
                SignUpMobilePage(pageController: _pageController),
                ForgotPasswordMobilePage(pageController: _pageController),
                ForgotOtpMobilePage(
                  pageController: _pageController,
                  userId: userId,
                  pinToken: pinToken,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  static const String name = 'signin';
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var currentYear = DateTime.now().year;
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      LandingBuildPage(
        top: true,
      ),
      const SizedBox(height: 10),
      LandingConnectPage(
        top: true,
      ),
      const SizedBox(height: 10),
      LandingPublishPage(
        top: true,
      ),
      const SizedBox(height: 10),
      const Divider(),
      Text(
        "Copyright © $currentYear Boodskap Inc, All rights reserved",
        style: getBodyTextStyle(context),
      ),
    ];
    Color bgColor = Colors.black;

    if (null != twinSysInfo && twinSysInfo!.landingPages!.isNotEmpty) {
      bgColor = Colors.white;
      children.clear();

      if (null != twinSysInfo && twinSysInfo!.bannerImage!.isNotEmpty) {
        var banner = UserSession()
            .getImage(domainKey, twinSysInfo!.bannerImage!, fit: BoxFit.cover);
        children.add(SizedBox(height: 125, child: banner));
        children.add(const SizedBox(
          height: 8,
        ));
      }

      for (var element in twinSysInfo!.landingPages!) {
        children.add(CustomLandingPage(
          landingPage: element,
          textOrientation: TextOrientation.top,
        ));
        //children.add(const Divider());
      }
    }

    // Tablet or larger view
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 380,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              children: [
                NavigationControl(
                  onCreateAccountPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
