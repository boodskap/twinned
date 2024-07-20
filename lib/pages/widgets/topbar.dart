import 'package:flutter/material.dart';
import 'package:twinned/core/ui.dart';
import 'package:twinned/core/user_session.dart';

class TopBar extends StatelessWidget {
  final String title;
  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      color: const Color(0xFF0C244A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: 'Go back',
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.keyboard_double_arrow_left,
                  color: Colors.white,
                )),
          ),
          Expanded(
              child: Center(
            child: Text(
              title,
              style: UserSession.getAppTextStyle(),
            ),
          )),
          Row(
            children: [
              Tooltip(
                message: "Logout",
                child: IconButton(
                    onPressed: () {
                      UI().logout(context);
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
