// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned/core/app_logo.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/core/user_session.dart';
import 'package:verification_api/api/verification.swagger.dart';

class ResetPasswordpage extends StatefulWidget {
  final PageController pageController;
  final String userId;
  final String pinToken;
  final String pin;

  const ResetPasswordpage(
      {super.key,
      required this.userId,
      required this.pinToken,
      required this.pin,
      required this.pageController});

  @override
  State<ResetPasswordpage> createState() => _ResetPasswordpageState();
}

class _ResetPasswordpageState extends BaseState<ResetPasswordpage> {
  final GlobalKey<_ResetPasswordpageState> _key = GlobalKey();

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
  void setup() {}

  void _doChangePassword() async {
    busy();
    String userId = UserSession().getRegisterDets()?.userId ?? '';
    String pinToken = UserSession().getRegisterDets()?.pinToken ?? '';
    String pin = UserSession().getRegisterDets()?.pin ?? '';

    try {
      final ResetPassword body = ResetPassword(
        userId: userId,
        pinToken: pinToken,
        pin: pin,
        password: _conPassController.text,
      );
      var res = await UserSession.vapi.resetPassword(
        dkey: domainKey,
        body: body,
      );
      if (res.body!.ok) {
        var dets = ResetPassword(
            userId: userId,
            pinToken: pinToken,
            pin: pin,
            password: _conPassController.text);
        UserSession().setRegisterDets(dets);
        alert("Password changed successfully", "");
        widget.pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else {
        alert(
          "Password not changed",
          res.body!.msg ?? '',
        );
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
              'Set Your New Password',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "New Password",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
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
                      ),
                      obscureText: isObscurednew,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "New Password Required";
                        }
                        return null;
                      },
                    ),
                    const Text(
                      "Confirm Password",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
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
                      ),
                      obscureText: isObscured,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm Password Required";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0Xff375ee9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(340, 50),
                ),
                onPressed: () async {
                  debugPrint('Proceed pressed');
                  if (formKey.currentState!.validate()) {
                    if (_newPassController.text == _conPassController.text) {
                      _doChangePassword();
                    } else {
                      alert(" ", "Password Mismatch");
                    }
                  }
                },
                child: !isLoading
                    ? const Text(
                        "Proceed",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    : const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          backgroundColor: Colors.transparent,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
              ),
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
