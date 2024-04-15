// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned/core/app_logo.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/pages/login/page_forgot_otp_passowrd.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:verification_api/api/verification.swagger.dart';

class VerifyOtpPage extends StatefulWidget {
  final RegistrationRes? registrationRes;
  const VerifyOtpPage({
    super.key,
    required this.pageController,
    required this.registrationRes,
  });
  final PageController pageController;
  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends BaseState<VerifyOtpPage> {
  final GlobalKey<_VerifyOtpPageState> _key = GlobalKey();
  final TextStyle h2 = GoogleFonts.acme(
    color: Colors.deepPurple,
    fontSize: 20,
  );

  TextEditingController pinController = TextEditingController();

  GlobalKey<State<StatefulWidget>> getKey() {
    return _key;
  }

  @override
  void setup() async {
    String? pin = await Constants.getString("saved.pin", "");
    setState(() {
      pinController.text = pin;
    });
  }

  void _doShowResetPassword(String userId, String pinToken, String pin) {
    widget.pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _doVerifyPin() async {
    busy();
    String pinToken = UserSession().getRegisterDets()?.pinToken ?? '';

    try {
      var body = VerificationReq(
        pinToken: pinToken,
        pin: pinController.text,
      );

      var res = await UserSession.vapi.verifyPin(
        dkey: domainKey,
        body: body,
      );

      if (res.body!.ok) {
        var dets = ResetPassword(
            userId: res.body!.user.email,
            pinToken: pinToken,
            pin: body.pin,
            password: "");
        UserSession().setRegisterDets(dets);
        _doShowResetPassword(
            res.body!.user.email, body.pinToken, pinController.text);
      } else {
        alert('Error', res.body!.msg);
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: AppLogo(),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              "Verify your OTP",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            OtpForm(pinController: pinController),
            const SizedBox(
              height: 80,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0Xfff7f2f9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(150, 40),
                    ),
                    onPressed: () async {
                      widget.pageController.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'Cancel',
                      style: h2,
                    )),
                const BusyIndicator(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(150, 40),
                  ),
                  onPressed: () async {
                    if (pinController.text.isNotEmpty) {
                      if (pinController.text.length == 6) {
                        _doVerifyPin();
                      } else {
                        alert("Pin length mismatch", "");
                      }
                    } else {
                      alert("", "Pin required");
                    }
                  },
                  child: Text(
                    'Verify',
                    style: h2.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Powered By",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
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
      ],
    );
  }
}
