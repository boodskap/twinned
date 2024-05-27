import 'dart:html' as html;

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
import 'package:twinned_widgets/twinned_session.dart';
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

class LoginPage extends StatefulWidget {
  final PageController pageController;

  // static const String name = 'signin';
  const LoginPage({super.key, required this.pageController});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends BaseState<LoginPage> {
  final GlobalKey<_LoginPageState> _key = GlobalKey();
  final formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  bool _canSignup = false;
  bool _customBranding = false;
  bool _rememberMe = false;

  GlobalKey<State<StatefulWidget>> getKey() {
    return _key;
  }

  @override
  void initState() {
    _canSignup = defaultDomainKey != domainKey;
    _customBranding = twinSysInfo != null && defaultDomainKey != domainKey;
    if (_customBranding) {
      _canSignup = twinSysInfo?.enableSelfRegistration ?? false;
    }
    super.initState();
  }

  @override
  void setup() async {
    String? user = await Constants.getString("saved.user", "");
    String? password = await Constants.getString("saved.password", "");
    bool? remember = await Constants.getBool("remember.me", _rememberMe);

    if (defaultDomainKey == domainKey) {
      user = 'try@boodskap.io';
      password = user;
    }

    setState(() {
      _userController.text = user ?? '';
      _passwordController.text = password ?? '';
      _rememberMe = remember;
    });
  }

  void _showHome() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => const HomePage()));
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

        var pRes = await UserSession.twin
            .getMyProfile(apikey: UserSession().getAuthToken());

        if (validateResponse(pRes)) {
          UserSession().twinUser = pRes.body!.entity;
          debugPrint(pRes.body!.entity.toString());
        }

        TwinnedSession.instance.init(
            debug: debug,
            host: hostName,
            authToken: UserSession().getAuthToken(),
            domainKey: UserSession().twinUser?.domainKey ?? '');

        _showHome();
      }
    });
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
                    hintText: "Enter your mail", controller: _userController),
                const SizedBox(
                  height: 10,
                ),
                PasswordField(
                    hintText: "Enter your password",
                    controller: _passwordController),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                          ),
                          Text(
                            'Remember Me',
                            style: UserSession().getLabelFontStyle(),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      child: Text(
                        'Forgot your password?',
                        style: UserSession()
                            .getLabelFontStyle()
                            .copyWith(color: loginBgColor),
                      ),
                      onTap: () {
                        widget.pageController.animateToPage(4,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
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
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: UserSession().getLabelFontStyle(),
                        )),
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
                        style: UserSession()
                            .getLabelFontStyle()
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_canSignup)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: UserSession().getLabelFontStyle(),
                      ),
                      TextButton(
                          onPressed: () {
                            widget.pageController.jumpToPage(3);
                          },
                          child: Text(
                            "SignUp",
                            style: UserSession().getLabelFontStyle(),
                          ))
                    ],
                  ),
                if (!_canSignup && !_customBranding)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Create Digital Twins by Signing Up"),
                      divider(height: 10, horizontal: false),
                      InkWell(
                        child: const Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              'NoCode Builder',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            SizedBox(
                                height: 16,
                                width: 16,
                                child: Icon(
                                  Icons.open_in_new_outlined,
                                  size: 16,
                                ))
                          ],
                        ),
                        onTap: () {
                          html.window.open(nocodeUrl(), 'new tab');
                        },
                      ),
                      if (_canSignup)
                        TextButton(
                            onPressed: () {
                              widget.pageController.jumpToPage(3);
                            },
                            child: const Text("SignUp")),
                      if (!_canSignup) divider(height: 20),
                      if (!_canSignup)
                        const Text(
                          'GET A SELF DEMO',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey),
                        ),
                      if (!_canSignup) divider(height: 10),
                      if (!_canSignup)
                        const Text(
                          'try@boodskap.io / try@boodskap.io',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
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
                  const SizedBox(width: 10),
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
