import 'package:flutter/material.dart';
import 'user_session.dart';

typedef OnPopped = void Function();

class UI {
  static final UI _instance = UI._internal();

  factory UI() {
    return _instance;
  }

  UI._internal();

  bool checkSesion(BuildContext context) {
    return null != UserSession().loginResponse;
  }

  void pushPage(BuildContext context, Widget page, OnPopped onPopped) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Material(
                  child: page,
                ))).then((value) => {
          debugPrint('**RETURNING** back to ${page.runtimeType.toString()}'),
          onPopped()
        });
  }

  void pushReplacementPage(
      BuildContext context, Widget page, OnPopped onPopped) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Material(
                  child: page,
                ))).then((value) => {
          debugPrint('**RETURNING** back to ${page.runtimeType.toString()}'),
          onPopped()
        });
  }

  void logout(BuildContext context) {
    UserSession().cleanup();

    Navigator.pushNamed(context, '/');
  }

  void show(BuildContext context, String title, String text,
      {int duration = 1}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(
            text,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
    Future.delayed(
      Duration(seconds: duration),
      () {
        Navigator.of(context).pop();
        debugPrint("pop up closed");
      },
    );
  }
}
