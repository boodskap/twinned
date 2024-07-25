import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as web;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final bool development = bool.parse(dotenv.env['DEVELOPMENT'] ?? 'true');

final bool debug = bool.parse(dotenv.env['DEBUG'] ?? 'true');

final String defaultDomainKey =
    development ? dotenv.env['D_DOMAIN_KEY']! : dotenv.env['P_DOMAIN_KEY']!;

String domainKey = defaultDomainKey;

final String hostName =
    development ? dotenv.env['D_HOST_NAME']! : dotenv.env['P_HOST_NAME']!;

final String mqttTcpUrl =
    development ? dotenv.env['D_MQTT_HOST']! : dotenv.env['P_MQTT_HOST']!;

final String mqttWsUrl = 'wss://$mqttTcpUrl/mqtt';

final int mqttTcpPort = development
    ? int.parse(dotenv.env['D_MQTT_TCP_PORT']!)
    : int.parse(dotenv.env['P_MQTT_TCP_PORT']!);

final int mqttWsPort = development
    ? int.parse(dotenv.env['D_MQTT_WS_PORT']!)
    : int.parse(dotenv.env['P_MQTT_WS_PORT']!);

final String defaultFont = dotenv.env['DEFAULT_FONT'] ?? 'Open Sans';

twinned.TwinSysInfo? twinSysInfo;

String nocodeUrl() {
  return development ? 'https://nocode.boodskap.io' : 'https://nocode.build';
}

String paymentUrl() {
  return !development
      ? 'https://pay.boodskap.io/p/login/bIY02IdHc4wC8es8ww'
      : 'https://pay.boodskap.io/p/login/bIY02IdHc4wC8es8ww';
}

const String applicationName = 'No Code';

/// change the subject line for the activation emails accoring to your needs
final String emailSubject = dotenv.env['EMIL_SUBJECT']!;

/// create activation template at elasticemail.com and change content according to your needs
final String activationTemplate = dotenv.env['ACTIVATION_TEMPLATE']!;

/// create reset password template at elasticemail.com and change content according to your needs
final String resetPswdTemplate = dotenv.env['RESET_PSWD_TEMPLATE']!;

const List<String> roles = ["orgadmin"];

final Color overlayColor = Colors.black.withOpacity(.5);
const Color linkColor = Color(0xFFFFFFFF);
const Color poweredByColor = Colors.grey;
const Color bgColor = Color(0xFF202124);
const Color textPrimary = Color(0xFFFFFFFF);
const Color textSecondary = Color(0xFF3A3A3A);
const Color loginBgColor = Color(0xFF35729B); //Color(0xFFF7C4A5);
const Color logoBgColor = Color(0xFFFFFFFF);
const Color loginTextColor = Color(0xFF66519D);
const Color loginBtnColor = Color(0xFFF7F2F9);

// Margin
const EdgeInsets marginBottom8 = EdgeInsets.only(bottom: 8);
const EdgeInsets marginBottom12 = EdgeInsets.only(bottom: 12);
const EdgeInsets marginBottom24 = EdgeInsets.only(bottom: 24);
const EdgeInsets marginBottom40 = EdgeInsets.only(bottom: 40);

// Padding
const EdgeInsets paddingBottom24 = EdgeInsets.only(bottom: 24);

const double paletteWidth = 275;
const double paletteIconSize = 18;
const double toolBarIconSize = 20;
const double propertiesWidth = 300;
const double propertyIconSize = 14;

const Size mobileSize = Size(450, 825);
const Size tabletSize = Size(925, 625);
const Size desktopSize = Size(double.infinity, double.infinity);

String imageUrl(String domainKey, String id) {
  return '${UserSession.vapi.client.baseUrl}/Image/download/$domainKey/$id';
}

String twinImageUrl(String domainKey, String id) {
  //debugPrint('downloading domain:$domainKey, id: $id');
  return '${UserSession.twin.client.baseUrl}/TwinImage/download/$domainKey/$id';
}

Future<twinned.ImageFileEntityRes> uploadTwinImage({
  required twinned.TwinImageUploadModelImageTypeModelIdPostImageType imageType,
  required twinned.TwinImageUploadModelImageTypeModelIdPostImageType
      imageTarget,
  String? modelId,
  String? deviceId,
  String? alarmId,
  String? conditionId,
  String? controlId,
  String? eventId,
  String? triggerId,
  required List<int> file,
  required String fileName,
}) async {
  var mpr = web.MultipartRequest(
    "POST",
    Uri.https(
      hostName,
      "/rest/nocode/TwinImage/upload/${imageType.value!}/${imageTarget.value}",
    ),
  );
  mpr.headers['APIKEY'] = UserSession().getAuthToken();
  if (null != modelId) mpr.headers['modelId'] = modelId;
  if (null != deviceId) mpr.headers['deviceId'] = deviceId;
  if (null != alarmId) mpr.headers['alarmId'] = alarmId;
  if (null != conditionId) mpr.headers['conditionId'] = conditionId;
  if (null != controlId) mpr.headers['controlId'] = controlId;
  if (null != eventId) mpr.headers['eventId'] = eventId;
  if (null != triggerId) mpr.headers['pageId'] = triggerId;
  mpr.files.add(
    web.MultipartFile.fromBytes('file', file, filename: fileName),
  );
  log("uploading... ${mpr.url}");
  var stream = await mpr.send();
  log("extracting...");
  var response = await stream.stream.bytesToString();
  debugPrint("decoding: $response...");
  var map = jsonDecode(response) as Map<String, dynamic>;
  log("converting...");
  return twinned.ImageFileEntityRes.fromJson(map);
}

TextStyle getHeadlineTextStyle(BuildContext context) {
  double fontSize = 50;

  if (ResponsiveBreakpoints.of(context).between(MOBILE, TABLET)) {
    fontSize = 25;
  }
  return GoogleFonts.montserrat(
      textStyle: TextStyle(
          fontSize: fontSize,
          color: textPrimary,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w300));
}

TextStyle getHeadlineSecondaryTextStyle(BuildContext context) {
  double fontSize = 40;

  if (ResponsiveBreakpoints.of(context).between(MOBILE, TABLET)) {
    fontSize = 20;
  } else if (ResponsiveBreakpoints.of(context).smallerThan(MOBILE)) {
    fontSize = 16;
  }

  return GoogleFonts.montserrat(
      textStyle: TextStyle(
          fontSize: fontSize, color: textPrimary, fontWeight: FontWeight.w300));
}

TextStyle getSubtitleTextStyle(BuildContext context) {
  double fontSize = 28;

  if (ResponsiveBreakpoints.of(context).between(MOBILE, TABLET)) {
    fontSize = 14;
  }
  return GoogleFonts.openSans(
      textStyle: TextStyle(
          fontSize: fontSize, color: textSecondary, letterSpacing: 1));
}

TextStyle getBodyTextStyle(BuildContext context) {
  double fontSize = 18;

  if (ResponsiveBreakpoints.of(context).between(MOBILE, TABLET)) {
    fontSize = 14;
  }
  return GoogleFonts.openSans(
      textStyle: TextStyle(fontSize: fontSize, color: textPrimary));
}

TextStyle buttonTextStyle = GoogleFonts.montserrat(
    textStyle:
        const TextStyle(fontSize: 14, color: textPrimary, letterSpacing: 1));

bool isBlank(String text) {
  return text.isEmpty;
}

bool isBoolean(String text) {
  return (text == 'true' || text == 'false');
}

class Constants {
  static final Lock lock = Lock();

  static Future<bool> putString(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = await sp.setString(key, value);
    return res;
  }

  static Future<bool> putInt(String key, int value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setInt(key, value);
  }

  static Future<bool> putBool(String key, bool value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool(key, value);
  }

  static Future<bool> putDouble(String key, double value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setDouble(key, value);
  }

  static Future<bool> putStringList(String key, List<String> value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setStringList(key, value);
  }

  static Future<bool> getBool(String key, bool def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getBool(key);
    return res ?? def;
  }

  static Future<String> getString(String key, String def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getString(key);
    return res ?? def;
  }

  static Future<int> getInt(String key, int def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getInt(key);
    return res ?? def;
  }

  static Future<double> getDouble(String key, double def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getDouble(key);
    return res ?? def;
  }

  static Future<List<String>> getStringList(
      String key, List<String> def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getStringList(key);
    return res ?? def;
  }
}
