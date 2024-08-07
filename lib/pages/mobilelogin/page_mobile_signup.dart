import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned/core/app_logo.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned/pages/login/page_forgot_password.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twinned/widgets/commons/userid_field.dart';
import 'package:twinned/widgets/commons/validated_text_field.dart';
import 'package:verification_api/api/verification.swagger.dart';

class SignUpMobilePage extends StatefulWidget {
  const SignUpMobilePage({super.key, required this.pageController});
  final PageController pageController;
  @override
  State<SignUpMobilePage> createState() => _SignUpMobilePageState();
}

class _SignUpMobilePageState extends BaseState<SignUpMobilePage> {
  final GlobalKey<_SignUpMobilePageState> _key = GlobalKey();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool isLoading = false;

  final eFormKey = GlobalKey<FormState>();
  final pFormKey = GlobalKey<FormState>();

  GlobalKey<State<StatefulWidget>> getKey() {
    return _key;
  }

  @override
  void setup() async {
    String? fname = await Constants.getString("saved.fname", "");
    String? lname = await Constants.getString("saved.lname", "");
    String? email = await Constants.getString("saved.email", "");

    setState(() {
      _fnameController.text = fname;
      _lnameController.text = lname;
      _emailController.text = email;
    });
  }

  void _showOtpPage(RegistrationRes registrationRes) {
    widget.pageController.jumpToPage(1);
  }

  void _doSignUp() async {
    busy();
    try {
      var fname = _fnameController.text;
      var lname = _lnameController.text;
      var email = _emailController.text;

      var body = Registration(
        phone: "",
        email: email,
        roles: roles,
        subject: emailSubject,
        template: activationTemplate,
        fname: fname,
        lname: lname,
        properties: {},
      );

      var res = await UserSession.vapi.registerUser(
        dkey: domainKey,
        body: body,
      );

      if (res.body!.ok) {
        var dets = ResetPassword(
            userId: email, pinToken: res.body!.pinToken, pin: "", password: "");
        UserSession().setRegisterDets(dets);
        _showOtpPage(res.body!);
      } else {
        // ignore: use_build_context_synchronously
        alert('Error', res.body!.msg ?? '');
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    // ignore: use_build_context_synchronously
    busy(busy: false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Center(
                child: AppLogo(),
              ),
              Form(
                key: eFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Register New User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 15),
                    UseridField(
                      hintText: "Enter your email",
                      controller: _emailController,
                    ),
                    const SizedBox(height: 15),
                    ValidatedTextField(
                        hintText: "Enter the firstname",
                        controller: _fnameController,
                        minLength: 1),
                    const SizedBox(height: 15),
                    ValidatedTextField(
                      hintText: "Enter the lastname",
                      controller: _lnameController,
                      minLength: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0Xfff7f2f9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(130, 40),
                      ),
                      onPressed: () {
                        debugPrint('Cancel pressed');
                        widget.pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0Xff6E58A8),
                          fontSize: 14,
                        ),
                      )),
                  const BusyIndicator(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(130, 40),
                    ),
                    onPressed: () {
                      if (eFormKey.currentState!.validate()) {
                        _doSignUp();
                      }
                    },
                    child: Text(
                      "Sign Up",
                      style: h2.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.pageController.animateToPage(0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
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
      ),
    );
  }
}
