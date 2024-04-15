import 'package:flutter/material.dart';

class DesignView extends StatefulWidget {
  const DesignView({super.key});

  @override
  State<DesignView> createState() => _DesignViewState();
}

class _DesignViewState extends State<DesignView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          SizedBox(
            width: 350,
            height: 350,
            child: Container(
              color: Colors.red,
            ),
          ),
          SizedBox(
            width: 350,
            height: 350,
            child: CustomPaint(
              painter: MakeCircle(),
            ),
          )
        ],
      ),
    );
  }
}

class MakeCircle extends CustomPainter {
  final double strokeWidth;

  MakeCircle({this.strokeWidth = 12.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke; //important set stroke style

    final path0 = Path()
      ..addOval(Rect.fromLTRB(0, 0, size.width, 20))
      ..close();

    final path1 = Path()
      ..lineTo(0, size.height)
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    final path2 = Path()
      ..addArc(
          Rect.fromLTRB(0, size.height - 20, size.width, size.height), 30, 30)
      ..close();

    canvas.drawPath(path0, paint);
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DesignPage extends StatefulWidget {
  const DesignPage({super.key});

  @override
  State<DesignPage> createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DesignView(),
    );
  }
}
