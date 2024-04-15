import 'package:flutter/material.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';

class AppLogo extends StatelessWidget {
  double size;
  bool withText;
  Color? textColor;
  AppLogo(
      {super.key,
      this.withText = true,
      this.textColor = Colors.blue,
      this.size = 150});

  @override
  Widget build(BuildContext context) {
    Widget image =
        Image.asset('assets/images/logo-large.png', fit: BoxFit.contain);

    if (null != twinSysInfo && twinSysInfo!.logoImage!.isNotEmpty) {
      image = UserSession()
          .getImage(domainKey, twinSysInfo!.logoImage!, fit: BoxFit.contain);
      withText = false;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Column(
        children: [
          SizedBox(
              width: withText ? 60 : 95,
              height: withText ? 60 : 95,
              child: image),
          const SizedBox(
            height: 4,
          ),
          if (withText)
            const Text(
              'digitaltwin',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
        ],
      ),
    );
  }
}
