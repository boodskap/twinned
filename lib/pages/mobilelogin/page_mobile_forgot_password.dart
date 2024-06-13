// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned/core/app_logo.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned/widgets/commons/userid_field.dart';
import 'package:verification_api/api/verification.swagger.dart';

final TextStyle h1 = GoogleFonts.montserrat(
    color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600);

final TextStyle h2 = GoogleFonts.montserrat(
  color: loginTextColor,
  fontSize: 16,
);

GlobalKey<FormState> gkeyUserId = GlobalKey();

class ForgotPasswordMobilePage extends StatefulWidget {
  final PageController pageController;

  static const String name = 'forgotPassword';
  const ForgotPasswordMobilePage({super.key, required this.pageController});

  @override
  State<ForgotPasswordMobilePage> createState() =>
      _ForgotPasswordMobilePageState();
}

class _ForgotPasswordMobilePageState
    extends BaseState<ForgotPasswordMobilePage> {
  final TextEditingController _userEmail = TextEditingController();
  final GlobalKey<_ForgotPasswordMobilePageState> _key = GlobalKey();
  final formKey = GlobalKey<FormState>();

  GlobalKey<State<StatefulWidget>> getKey() {
    return _key;
  }

  @override
  void setup() async {
    String? userEmail = await Constants.getString("saved.userEmail", "");
    setState(() {
      _userEmail.text = userEmail;
    });
  }

  void _showForgotOtpPage(String userId, String pinToken) {
    widget.pageController.animateToPage(
      5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _doChangePassEmail() async {
    busy();

    try {
      var userEmail = _userEmail.text;
      var body = ForgotPassword(
        userId: userEmail,
        subject: emailSubject,
        template: resetPswdTemplate,
      );

      var res = await UserSession.vapi.forgotPassword(
        dkey: domainKey,
        body: body,
      );

      if (res.body!.ok) {
        var dets = ResetPassword(
            userId: userEmail,
            password: "",
            pin: "",
            pinToken: res.body!.pinToken);
        UserSession().setRegisterDets(dets);
        _showForgotOtpPage(body.userId ?? '', res.body!.pinToken ?? '');
      } else {
        alert("Error", res.body!.msg ?? '');
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: logoBgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: AppLogo(),
                ),
                const SizedBox(height: 30),
                Text(
                  'Reset Your Password',
                  style: h1,
                ),
                const SizedBox(
                  height: 40,
                ),
                Form(
                  key: formKey,
                  child: UseridField(
                    hintText: "Enter your email",
                    controller: _userEmail,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: loginBtnColor,
                        minimumSize: const Size(130, 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        widget.pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      child: Text(
                        'Cancel',
                        style: h2,
                      ),
                    ),
                    const BusyIndicator(width: 20, height: 20, padding: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(90, 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _doChangePassEmail();
                        }
                      },
                      child: Text(
                        'Generate OTP',
                        style: h2.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account ? ",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.pageController.animateToPage(3,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      child: const Text(
                        "SIGN UP!",
                        style: TextStyle(
                            fontSize: 15,
                            color: loginBgColor,
                            decoration: TextDecoration.none),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Powered By",
                    style: TextStyle(color: poweredByColor, fontSize: 16),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Image.asset(
                    "assets/images/poweredby.png",
                    width: 150,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
