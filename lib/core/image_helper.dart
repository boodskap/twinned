import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as web;
import 'package:twinned/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

class ImageHelper {
  static const String _twinHost = 'nocode.build';

  static Future<twin.ImageFileEntityRes> _upload(
      web.MultipartRequest mpr, String fileName, List<int> file) async {
    mpr.headers['APIKEY'] = UserSession().getAuthToken();

    mpr.files.add(
      web.MultipartFile.fromBytes('file', file, filename: fileName),
    );

    debugPrint("uploading... ${mpr.url}");
    var stream = await mpr.send();
    log("extracting...");
    var response = await stream.stream.bytesToString();
    debugPrint("decoding: $response...");
    var map = jsonDecode(response) as Map<String, dynamic>;
    log("converting...");
    return twin.ImageFileEntityRes.fromJson(map);
  }

  static Future<twin.ImageFileEntityRes> uploadDeviceModelIcon(
      {required String modelId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/model/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}/$modelId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDeviceModelImage(
      {required String modelId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/model/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.image.value}/$modelId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDeviceModelBanner(
      {required String modelId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/model/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.banner.value}/$modelId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadConditionIcon(
      {required String conditionId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/condition/$conditionId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadAlarmIcon(
      {required String alarmId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/alarm/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}/$alarmId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDisplayIcon(
      {required String displayId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/display/$displayId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadControlIcon(
      {required String controlId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/control/$controlId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadEventIcon(
      {required String eventId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/event/$eventId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadTriggerIcon(
      {required String triggerId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/trigger/$triggerId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDeviceIcon(
      {required String deviceId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/device/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}/$deviceId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDeviceImage(
      {required String deviceId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/device/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.image.value}/$deviceId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDeviceBanner(
      {required String deviceId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/device/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.banner.value}/$deviceId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadMenuIcon(
      {required int menuIndex,
      required String menuId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/menu/$menuIndex/$menuId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadMenuGroupIcon(
      {required String menuGroupId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/menugroup/$menuGroupId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadScreenBanner(
      {required String screenId,
      required String fileName,
      required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/screen/$screenId",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDomainIcon(
      {required String fileName, required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDomainImage(
      {required String fileName, required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.image.value}",
      ),
    );

    return _upload(mpr, fileName, file);
  }

  static Future<twin.ImageFileEntityRes> uploadDomainBanner(
      {required String fileName, required List<int> file}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        _twinHost,
        "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.banner.value}",
      ),
    );

    return _upload(mpr, fileName, file);
  }
}
