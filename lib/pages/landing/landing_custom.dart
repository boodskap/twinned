import 'package:flutter/material.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:google_fonts/google_fonts.dart';

enum TextOrientation { left, top, right, bottom }

class CustomLandingPage extends StatefulWidget {
  final twinned.LandingPage landingPage;
  final TextOrientation textOrientation;
  const CustomLandingPage({
    super.key,
    required this.landingPage,
    required this.textOrientation,
  });

  @override
  State<CustomLandingPage> createState() => _CustomLandingPageState();
}

class _CustomLandingPageState extends State<CustomLandingPage> {
  Widget? image;
  final List<Widget> lines = [];

  @override
  void initState() {
    if (widget.landingPage.heading!.isNotEmpty) {
      lines.add(Text(
        widget.landingPage.heading!,
        maxLines: 2,
        style: GoogleFonts.getFont(
          twinSysInfo?.headerFont ?? defaultFont,
          color: Color(twinSysInfo?.headerFontColor ?? Colors.black.value),
          fontSize: twinSysInfo?.headerFontSize ?? 50,
        ),
      ));
    }

    lines.add(const SizedBox(
      height: 20,
    ));

    if (widget.landingPage.subHeading!.isNotEmpty) {
      lines.add(Text(
        widget.landingPage.subHeading!,
        maxLines: 3,
        style: GoogleFonts.getFont(twinSysInfo?.subHeaderFont ?? defaultFont,
            color: Color(twinSysInfo?.subHeaderFontColor ?? Colors.black.value),
            fontSize: twinSysInfo?.subHeaderFontSize ?? 50),
      ));
    }

    lines.add(const SizedBox(
      height: 15,
    ));

    if (widget.landingPage.line1!.isNotEmpty) {
      lines.add(Text(
        widget.landingPage.line1!,
        maxLines: 5,
        style: GoogleFonts.getFont(twinSysInfo?.font ?? defaultFont,
            color: Color(twinSysInfo?.fontColor ?? Colors.black.value),
            fontSize: twinSysInfo?.fontSize ?? 50),
      ));
    }

    lines.add(const SizedBox(
      height: 10,
    ));

    if (widget.landingPage.line2!.isNotEmpty) {
      lines.add(Text(
        widget.landingPage.line2!,
        maxLines: 5,
        style: GoogleFonts.getFont(twinSysInfo?.font ?? defaultFont,
            color: Color(twinSysInfo?.fontColor ?? Colors.black.value),
            fontSize: twinSysInfo?.fontSize ?? 50),
      ));
    }

    lines.add(const SizedBox(
      height: 10,
    ));

    if (widget.landingPage.line3!.isNotEmpty) {
      lines.add(Text(
        widget.landingPage.line3!,
        maxLines: 5,
        style: GoogleFonts.getFont(twinSysInfo?.font ?? defaultFont,
            color: Color(twinSysInfo?.fontColor ?? Colors.black.value),
            fontSize: twinSysInfo?.fontSize ?? 50),
      ));
    }

    lines.add(const SizedBox(
      height: 10,
    ));

    if (widget.landingPage.line4!.isNotEmpty) {
      lines.add(Text(
        widget.landingPage.line4!,
        maxLines: 5,
        style: GoogleFonts.getFont(twinSysInfo?.font ?? defaultFont,
            color: Color(twinSysInfo?.fontColor ?? Colors.black.value),
            fontSize: twinSysInfo?.fontSize ?? 50),
      ));
    }

    lines.add(const SizedBox(
      height: 10,
    ));

    if (widget.landingPage.line5!.isNotEmpty) {
      lines.add(Text(
        widget.landingPage.line5!,
        maxLines: 5,
        style: GoogleFonts.getFont(twinSysInfo?.font ?? defaultFont,
            color: Color(twinSysInfo?.fontColor ?? Colors.black.value),
            fontSize: twinSysInfo?.fontSize ?? 50),
      ));
    }

    if (widget.landingPage.logoImage?.isNotEmpty ?? false) {
      image = UserSession().getImage(domainKey, widget.landingPage.logoImage!,
          fit: BoxFit.cover);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.textOrientation) {
      case TextOrientation.left:
        return Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                flex: 40,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: lines,
                  ),
                ),
              ),
              Expanded(
                  flex: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [if (null != image) image!],
                  )),
            ],
          ),
        );
      case TextOrientation.top:
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            //color: Colors.white,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 8.0, color: Colors.lightBlue.shade600),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ...lines,
                  const SizedBox(
                    height: 8,
                  ),
                  if (null != image) image!,
                ],
              ),
            ),
          ),
        );
      case TextOrientation.right:
        return Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                  flex: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [if (null != image) image!],
                  )),
              Expanded(
                flex: 40,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: lines,
                  ),
                ),
              ),
            ],
          ),
        );
      case TextOrientation.bottom:
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            //color: Colors.white,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 8.0, color: Colors.lightBlue.shade600),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (null != image) image!,
                  if (null != image)
                    const SizedBox(
                      height: 8,
                    ),
                  ...lines,
                ],
              ),
            ),
          ),
        );
    }
  }
}
