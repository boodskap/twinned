import 'package:flutter/material.dart';
import 'package:twinned/pages/widgets/topbar.dart';

class ChildPage extends StatelessWidget {
  final String title;
  final Widget child;

  const ChildPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [TopBar(title: title), Flexible(child: child)],
      ),
    );
  }
}

Widget buildLink(String text, IconData icon, Function open,
    {Color color = Colors.green}) {
  return InkWell(
    onTap: () {
      open();
    },
    child: Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(width: 8),
        RichText(
            text: TextSpan(
                text: text,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14))),
      ],
    ),
  );
}
