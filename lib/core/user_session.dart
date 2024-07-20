import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'package:twin_commons/core/mqtt_connection.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:verification_api/api/verification.swagger.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  static final Verification vapi =
      Verification.create(baseUrl: Uri.https(hostName, '/rest/nocode'));

  static final twin =
      Twinned.create(baseUrl: Uri.https(hostName, '/rest/nocode'));

  static const String eventCellSelected = 'CellSelected';
  static const String eventCellRebuild = 'CellRebuild';
  static const String eventRowRebuild = 'RowRebuild';
  static const String eventRebuild = 'Rebuild';

  static bool _darkTheme = true;
  static const double _iconSize = 20;
  static const Color _lightIconColor = Color(0xFF7F8388);
  static const Color _darkIconColor = Color(0xFFFFFFEE);
  static const Color _dragIconColor = Color(0xFFF78C02);
  static const Color _lightSelectedIconColor = Colors.blue;
  static const Color _darkSelectedIconColor = Colors.blue;

  static const Color _lightPaletteBg = Color(0xFFF5F8FA);
  static const Color _darkPaletteBg = Color(0xFF252526);
  static const Color _darkContentBorderColor = Color(0xFF535353);
  static const Color _lightContentBorderColor = Color(0xFF96B7D5);
  static const Color _darkToolbarColor = Color(0xFF333333);
  static const Color _lightToolbarColor = Color(0xFF333333);
  static const Color _darkPaletteSectionColor = Color(0xFF2D2D2D);
  static const Color _lightPaletteSectionColor = Color(0xFFECECEC);
  static const _darkPaletteTextStyle =
      TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
  static const _lightPaletteTextStyle =
      TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold);
  static const _darkPropertyTextStyle =
      TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
  static const _lightPropertyTextStyle =
      TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold);

  static final TextStyle _darkLabelTextStyle = GoogleFonts.acme(
      color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
  static final TextStyle _lightLabelTextStyle = GoogleFonts.acme(
      color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  static final TextStyle _darkPaletteButtonTextStyle = GoogleFonts.acme(
    textStyle: const TextStyle(overflow: TextOverflow.fade),
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle _lightPaletteButtonTextStyle = GoogleFonts.acme(
      textStyle: const TextStyle(overflow: TextOverflow.fade),
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold);

  VerificationRes? loginResponse;
  ResetPassword? _registerdets;
  TwinUser? twinUser;
  TwinSysInfo? twinSysInfo;
  factory UserSession() {
    GoogleFonts.acme(
        color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
    return _instance;
  }

  static bool editMode = true;
  static double screenWidth = 0;
  static double screenHeight = 0;
  WorkAreaType workAreaType = WorkAreaType.mobile;
  Orientation orientation = Orientation.portrait;
  //NoCodeComponentModel? selectedModel;

  UserSession._internal();

  void cleanup() {
    loginResponse = null;
    MqttConnection().disconnect();
  }

  String getSelectImageId(int? selected, List<String>? ids,
      {BoxFit fit = BoxFit.contain}) {
    String id = '';

    if (ids?.isNotEmpty ?? false) {
      int idx = selected ?? 0;
      if (idx > ids!.length) {
        idx = 0;
      }
      id = ids[idx] ?? '';
    }

    return id;
  }

  Widget getImage(String domainKey, String? id,
      {BoxFit? fit = BoxFit.contain}) {
    if (id?.isNotEmpty ?? false) {
      return Image.network(twinImageUrl(domainKey, id!), fit: fit);
    }
    return const Icon(Icons.image);
  }

  final Dio rest = Dio();
  bool dioInited = false;

  Dio getRest() {
    if (!dioInited) {
      rest.options.connectTimeout = const Duration(seconds: 5);
      rest.options.receiveTimeout = const Duration(seconds: 3);
    }
    return rest;
  }

  String getAuthToken() {
    if (null != loginResponse) {
      //debugPrint('TOKEN: ${loginResponse!.authToken}');
      return loginResponse!.authToken ?? '';
    }
    return "";
  }

  TextStyle getHeaderFontStyle() {
    if (null != twinSysInfo) {
      return GoogleFonts.getFont(twinSysInfo!.headerFont ?? defaultFont,
          fontSize: twinSysInfo!.headerFontSize ?? 50,
          fontWeight: FontWeight.bold,
          color: Color(twinSysInfo!.headerFontColor ?? Colors.black.value));
    }
    return GoogleFonts.getFont(
      defaultFont,
      fontSize: 50,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle getSubHeaderFontStyle() {
    if (null != twinSysInfo) {
      return GoogleFonts.getFont(twinSysInfo!.subHeaderFont ?? defaultFont,
          fontSize: twinSysInfo!.subHeaderFontSize ?? 35,
          fontWeight: FontWeight.bold,
          color: Color(twinSysInfo!.subHeaderFontColor ?? Colors.black.value));
    }
    return GoogleFonts.getFont(
      defaultFont,
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle getGeneralFontStyle(
      {TextOverflow overflow = TextOverflow.ellipsis}) {
    if (null != twinSysInfo) {
      return GoogleFonts.getFont(twinSysInfo!.font ?? defaultFont,
              fontSize: twinSysInfo!.fontSize ?? 12,
              color: Color(twinSysInfo!.fontColor ?? Colors.black.value))
          .copyWith(overflow: overflow);
    }
    return GoogleFonts.getFont(defaultFont, fontSize: 12)
        .copyWith(overflow: overflow);
  }

  TextStyle getMenuFontStyle() {
    if (null != twinSysInfo) {
      return GoogleFonts.getFont(twinSysInfo!.menuFont ?? defaultFont,
          fontSize: twinSysInfo!.menuFontSize ?? 14,
          fontWeight: FontWeight.bold,
          color: Color(twinSysInfo!.menuFontColor ?? Colors.black.value));
    }
    return GoogleFonts.getFont(
      defaultFont,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle getToolMenuFontStyle() {
    if (null != twinSysInfo) {
      return GoogleFonts.getFont(twinSysInfo!.toolFont ?? defaultFont,
          fontSize: twinSysInfo!.toolFontSize ?? 14,
          fontWeight: FontWeight.bold,
          color: Color(twinSysInfo!.toolFontColor ?? Colors.black.value));
    }
    return GoogleFonts.getFont(
      defaultFont,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle getLabelFontStyle() {
    if (null != twinSysInfo) {
      return GoogleFonts.getFont(twinSysInfo!.labelFont ?? defaultFont,
          fontSize: twinSysInfo!.labelFontSize ?? 14,
          fontWeight: FontWeight.bold,
          color: Color(twinSysInfo!.labelFontColor ?? Colors.black.value));
    }
    return GoogleFonts.getFont(
      defaultFont,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }

  void setLoginResponse(VerificationRes res) {
    loginResponse = res.copyWith();
    debugPrint(loginResponse.toString());
    MqttConnection().connect(
        mqttUrl: mqttWsUrl,
        mqttPort: mqttWsPort,
        domainKey: loginResponse!.user!.domainKey!,
        authToken: loginResponse!.authToken!,
        connCounter: loginResponse!.connCounter!);
  }

  VerificationRes? getLoginResponse() {
    return loginResponse;
  }

  bool isAdmin() {
    return (null != twinUser &&
        twinUser!.platformRoles!.contains('domainadmin'));
  }

  void setTwinSysInfo(TwinSysInfo info) {
    twinSysInfo = info.copyWith();
  }

  TwinSysInfo? getTwinSysInfo() {
    return twinSysInfo;
  }

  // void setRegistrationResponse(RegistrationRes res){
  //   regResponse = res;
  // }

  // RegistrationRes? getRegistrationResponse(){
  //   return regResponse;
  // }

  void setRegisterDets(ResetPassword dets) {
    _registerdets = dets;
  }

  ResetPassword? getRegisterDets() {
    return _registerdets;
  }

  static void switchTheme() {
    UserSession._darkTheme = !UserSession._darkTheme;
  }

  static Color getIconColor() {
    return _darkTheme ? _darkIconColor : _lightIconColor;
  }

  static Color getSelectedIconColor() {
    return _darkTheme ? _darkSelectedIconColor : _lightSelectedIconColor;
  }

  static Color getDragIconColor() {
    return _dragIconColor;
  }

  static Color getPaletteBackgroundColor() {
    return _darkTheme ? _darkPaletteBg : _lightPaletteBg;
  }

  static Color getPaletteComponentColor() {
    return _darkTheme ? _darkContentBorderColor : _lightContentBorderColor;
  }

  static Color getToolbarColor() {
    return _darkTheme ? _darkToolbarColor : _lightToolbarColor;
  }

  static Color getPaletteSectionColor() {
    return _darkTheme ? _darkPaletteSectionColor : _lightPaletteSectionColor;
  }

  static TextStyle getPaletteTextStyle() {
    return _darkTheme ? _darkPaletteTextStyle : _lightPaletteTextStyle;
  }

  static TextStyle getPropertyTextStyle() {
    return _darkTheme ? _darkPropertyTextStyle : _lightPropertyTextStyle;
  }

  static TextStyle getLabelTextStyle() {
    return _darkTheme ? _darkLabelTextStyle : _lightLabelTextStyle;
  }

  static TextStyle getDrawerTextStyle() {
    return GoogleFonts.acme(color: Colors.black, fontSize: 16);
  }

  static TextStyle getAppTextStyle() {
    return GoogleFonts.acme(color: Colors.white, fontSize: 25);
  }

  static TextStyle getPopupTextStyle() {
    return GoogleFonts.acme(color: Colors.white, fontSize: 18);
  }

  static Color getDrawerColor() {
    return const Color(0xFF0C244A);
  }

  static TextStyle getPaletteButtonTextStyle() {
    return _darkTheme
        ? _darkPaletteButtonTextStyle
        : _lightPaletteButtonTextStyle;
  }

  static double getIconSize() {
    return _iconSize;
  }

  static double getToolbarWidth() {
    return _iconSize + 20;
  }
}

enum WorkAreaType { desktop, tablet, mobile }
