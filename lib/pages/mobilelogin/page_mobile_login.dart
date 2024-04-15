
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/core/app_logo.dart';
import 'package:twinned/pages/page_home.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned/widgets/commons/password_field.dart';
import 'package:twinned/widgets/commons/userid_field.dart';
import 'package:verification_api/api/verification.swagger.dart';

final TextStyle h1 = GoogleFonts.montserrat(
  color: Colors.black,
  fontSize: 30,
);

final TextStyle h2 = GoogleFonts.acme(
  color: loginTextColor,
  fontSize: 20,
);

GlobalKey<FormState> gkeyUserId = GlobalKey();
GlobalKey<FormState> gkeyPassword = GlobalKey();

class LoginMobilePage extends StatefulWidget {
  final PageController pageController;

  const LoginMobilePage({super.key, required this.pageController});

  @override
  State<LoginMobilePage> createState() => _LoginMobilePageState();
}

class _LoginMobilePageState extends BaseState<LoginMobilePage> {
  final GlobalKey<_LoginMobilePageState> _key = GlobalKey();
  final formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  bool _rememberMe = false;

  GlobalKey<State<StatefulWidget>> getKey() {
    return _key;
  }

  @override
  void setup() async {
    String? user = await Constants.getString("saved.user", "");
    String? password = await Constants.getString("saved.password", "");
    bool? remember = await Constants.getBool("remember.me", _rememberMe);

    setState(() {
      _userController.text = user;
      _passwordController.text = password;
      _rememberMe = remember;
    });
  }

  void _showHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
    );
  }

  Future _doLogin() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      var user = _userController.text;
      var password = _passwordController.text;
      var body = Login(userId: user, password: password);
      var res = await UserSession.vapi.loginUser(
        dkey: domainKey,
        body: body,
      );
      if (validateResponse(res)) {
        UserSession().setLoginResponse(res.body!);

        if (_rememberMe) {
          Constants.putString("saved.user", user);
          Constants.putString("saved.password", password);
          Constants.putBool("remember.me", true);
        } else {
          Constants.putString("saved.password", "");
          Constants.putBool("remember.me", false);
        }

        if (validateResponse(res)) {
          _showHome();
        }
      }
    });
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: logoBgColor,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: AppLogo(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Sign In',
                    style: h1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  UseridField(
                    hintText: "Enter your mail",
                    controller: _userController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  PasswordField(
                    hintText: "Enter your password",
                    controller: _passwordController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        child: const Text(
                          'Forgot your password?',
                          style: TextStyle(fontSize: 15, color: loginBgColor),
                        ),
                        onTap: () {
                          widget.pageController.animateToPage(
                            4,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0Xfff7f2f9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(140, 40),
                        ),
                        onPressed: () {
                          debugPrint('Cancel pressed');
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: h2,
                        ),
                      ),
                      const BusyIndicator(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(140, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            await _doLogin();
                          }
                        },
                        child: Text(
                          'Login',
                          style: h2.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          widget.pageController.jumpToPage(3);
                        },
                        child: const Text("SignUp"),
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
                      style: TextStyle(
                        color: poweredByColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Image.asset(
                      "assets/images/poweredby.png",
                      width: 150,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
