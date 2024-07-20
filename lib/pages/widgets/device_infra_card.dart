import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twin_commons/widgets/fillable_circle.dart';
import 'package:twin_commons/widgets/fillable_rectangle.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twin_commons/widgets/device_fields.dart';

import '../dashboard/page_device_history.dart';

class DeviceInfraCard extends StatefulWidget {
  final Device device;
  final bool popOnSelect;
  const DeviceInfraCard(
      {super.key, required this.device, this.popOnSelect = false});

  @override
  State<DeviceInfraCard> createState() => _DeviceInfraCardState();
}

class _DeviceInfraCardState extends BaseState<DeviceInfraCard> {
  static const Widget missingImage = Icon(
    Icons.question_mark,
    size: 150,
  );

  String premiseName = '';
  String facilityName = '';
  String floorName = '';
  String assetName = '';
  DeviceData? data;
  String reported = 'reported ?';
  Widget image = missingImage;
  CustomWidget? customWidget;

  @override
  void setup() async {
    await _load();
  }

  void _pop() {
    if (widget.popOnSelect) {
      Navigator.pop(context);
    }
  }

  Future _load() async {
    var pRes = await UserSession.twin.getPremise(
        apikey: UserSession().getAuthToken(),
        premiseId: widget.device.premiseId);

    if (validateResponse(pRes)) {
      premiseName = pRes.body!.entity!.name;
    }

    var fRes = await UserSession.twin.getFacility(
        apikey: UserSession().getAuthToken(),
        facilityId: widget.device.facilityId);

    if (validateResponse(fRes)) {
      facilityName = fRes.body!.entity!.name;
    }

    var flRes = await UserSession.twin.getFloor(
        apikey: UserSession().getAuthToken(), floorId: widget.device.floorId);

    if (validateResponse(flRes)) {
      floorName = flRes.body!.entity!.name;
    }

    var aRes = await UserSession.twin.getAsset(
        apikey: UserSession().getAuthToken(), assetId: widget.device.assetId);

    if (validateResponse(aRes)) {
      assetName = aRes.body!.entity!.name;
    }

    var ddRes = await UserSession.twin.getDeviceData(
        apikey: UserSession().getAuthToken(),
        deviceId: widget.device.id,
        isHardwareDevice: false);

    if (validateResponse(ddRes)) {
      data = ddRes.body?.data;
      var dt = DateTime.fromMillisecondsSinceEpoch(data?.updatedStamp ?? 0);
      reported = 'reported ${timeago.format(dt, locale: 'en')}';
    }

    if (null == customWidget) {
      var mRes = await UserSession.twin.getDeviceModel(
          apikey: UserSession().getAuthToken(), modelId: widget.device.modelId);
      if (validateResponse(mRes)) {
        var dm = mRes.body!.entity!;
        customWidget = dm.customWidget;
        if (missingImage == image) {
          int sId = dm.selectedImage ?? 0;
          if (dm.images!.length > sId) {
            image = UserSession()
                .getImage(widget.device.domainKey, dm.images![sId]);
          }
        }
      }
    }

    if (null != customWidget && null != data) {
      Map<String, dynamic> attributes =
          customWidget!.attributes as Map<String, dynamic>;
      Map<String, dynamic> deviceData = {};
      if (null != data) {
        deviceData = data!.data as Map<String, dynamic>;
      }

      switch (ScreenWidgetType.values.byName(customWidget!.id)) {
        case ScreenWidgetType.fillableRectangle:
          image = SizedBox(
              width: 250,
              height: 250,
              child:
                  FillableRectangle(attributes: attributes, data: deviceData));
          break;
        case ScreenWidgetType.fillableCircle:
          image = SizedBox(
              width: 250,
              height: 250,
              child: FillableCircle(attributes: attributes, data: deviceData));
          break;
      }
    }

    image = InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeviceHistoryPage(
                    deviceName: data!.deviceName ?? '-',
                    deviceId: data!.deviceId,
                    modelId: data!.modelId,
                    adminMode: false,
                  )),
        );
        _pop();
      },
      child: SingleChildScrollView(
        child: DeviceFields(
          device: widget.device,
          authToken: UserSession().getAuthToken(),
          twinned: UserSession.twin,
        ),
      ),
    );

    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.home,
                              size: 10,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: premiseName,
                                child: Text(
                                  premiseName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business,
                              size: 10,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: facilityName,
                                child: Text(
                                  facilityName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cabin,
                              size: 10,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: floorName,
                                child: Text(
                                  floorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.view_comfy,
                              size: 10,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: assetName,
                                child: Text(
                                  assetName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  divider(),
                  Text(
                    widget.device.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            divider(),
            Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(child: image),
                )),
            divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    reported,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
