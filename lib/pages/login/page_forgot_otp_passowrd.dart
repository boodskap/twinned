// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:pinput/pinput.dart';
import 'package:twinned/core/app_logo.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:verification_api/api/verification.swagger.dart';

class ForgotOtpPage extends StatefulWidget {
  final String userId;
  final String pinToken;
  final PageController pageController;

  const ForgotOtpPage({
    super.key,
    required this.pinToken,
    required this.userId,
    required this.pageController,
  });

  @override
  State<ForgotOtpPage> createState() => _ForgotOtpPageState();
}

class _ForgotOtpPageState extends BaseState<ForgotOtpPage> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _conPassController = TextEditingController();
  bool isObscured = true;
  bool isObscurednew = true;
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  GlobalKey<State<StatefulWidget>> getKey() {
    return _key;
  }

  @override
  void setup() async {
    String? pin = await Constants.getString("pin", "");
    String? newPass = await Constants.getString("newPass", "");
    String? conPass = await Constants.getString("conPass", "");

    setState(() {
      _pinController.text = pin;
      _newPassController.text = newPass;
      _conPassController.text = conPass;
    });
  }

  void _showLogin() {
    widget.pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _doEnterPass() async {
    busy();

    try {
      var pin = _pinController.text;
      var conPass = _conPassController.text;

      String pinToken = UserSession().getRegisterDets()?.pinToken ?? '';
      String userId = UserSession().getRegisterDets()?.userId ?? '';

      final ResetPassword body = ResetPassword(
        userId: userId,
        pinToken: pinToken,
        pin: pin,
        password: conPass,
      );
      var res = await UserSession.vapi.resetPassword(
        dkey: domainKey,
        body: body,
      );

      if (res.body!.ok) {
        alert("", "Password changed successfully");
        _showLogin();
      } else {
        alert(
          "Password not changed",
          res.body!.msg,
        );
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
  }

  final TextStyle h1 = GoogleFonts.montserrat(
    color: Colors.black,
    fontSize: 30,
  );
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
            const Text(
              'OTP And Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            OtpForm(
              pinController: _pinController,
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      controller: _newPassController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isObscurednew = !isObscurednew;
                            });
                          },
                          icon: isObscurednew
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        border: const OutlineInputBorder(),
                        hintText: "Enter New Password",
                      ),
                      obscureText: isObscurednew,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "New Password Required";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      controller: _conPassController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isObscured = !isObscured;
                            });
                          },
                          icon: isObscured
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        border: const OutlineInputBorder(),
                        hintText: "Enter Confirm Password",
                      ),
                      obscureText: isObscured,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm Password Required";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0Xff375ee9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(355, 50),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (_newPassController.text == _conPassController.text) {
                      if (_pinController.text.isNotEmpty) {
                        if (_pinController.text.length == 6) {
                          _doEnterPass();
                        } else {
                          alert("Pin length mismatch", "");
                        }
                      } else {
                        alert("", "Pin required");
                      }
                    } else {
                      alert("Password mismatch", "");
                    }
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Powered By',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                'assets/images/poweredby.png',
                width: 150,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class OtpForm extends StatelessWidget {
  final TextEditingController pinController;

  const OtpForm({super.key, required this.pinController});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(top: 40),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pinput(
                controller: pinController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(
                      color: const Color(0Xff375ee9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
