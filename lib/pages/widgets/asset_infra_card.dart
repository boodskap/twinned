import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/pages/dashboard/page_infra.dart';
import 'package:twinned/pages/page_child.dart';
import 'package:twinned/pages/widgets/role_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:nocode_commons/widgets/asset_fields.dart';

class AssetInfraCard extends StatefulWidget {
  final Asset asset;
  final bool popOnSelect;
  const AssetInfraCard(
      {super.key, required this.asset, this.popOnSelect = false});

  @override
  State<AssetInfraCard> createState() => _AssetInfraCardState();
}

class _AssetInfraCardState extends BaseState<AssetInfraCard> {
  static const Widget missingImage = Icon(
    Icons.question_mark,
    size: 150,
  );

  String premiseName = '';
  String facilityName = '';
  String floorName = '';
  String devices = '';
  DeviceData? data;
  String reported = 'reported ?';
  Widget image = missingImage;
  List<String> rolesSelected = [];

  @override
  void setup() async {
    rolesSelected = widget.asset.roles!;
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
        premiseId: widget.asset.premiseId);

    if (validateResponse(pRes)) {
      premiseName = pRes.body!.entity!.name;
    }

    var fRes = await UserSession.twin.getFacility(
        apikey: UserSession().getAuthToken(),
        facilityId: widget.asset.facilityId);

    if (validateResponse(fRes)) {
      facilityName = fRes.body!.entity!.name;
    }

    var flRes = await UserSession.twin.getFloor(
        apikey: UserSession().getAuthToken(), floorId: widget.asset.floorId);

    if (validateResponse(flRes)) {
      floorName = flRes.body!.entity!.name;
    }

    devices = '${widget.asset.devices?.length ?? 0} devices';

    var ddRes = await UserSession.twin.searchRecentDeviceData(
        apikey: UserSession().getAuthToken(),
        assetId: widget.asset.id,
        body: const FilterSearchReq(search: '*', page: 0, size: 1));

    if (validateResponse(ddRes)) {
      if (ddRes.body!.values!.isNotEmpty) {
        data = ddRes.body!.values!.first;
        data = ddRes.body!.values!.first;
        var dt = DateTime.fromMillisecondsSinceEpoch(data!.updatedStamp);
        reported = 'reported ${timeago.format(dt, locale: 'en')}';
      }
    }

    image = SingleChildScrollView(
      child: AssetFields(
        asset: widget.asset,
        authToken: UserSession().getAuthToken(),
        twinned: UserSession.twin,
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
                                message: widget.asset.name,
                                child: Text(
                                  widget.asset.name,
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
                ],
              ),
            ),
            divider(),
            Expanded(flex: 4, child: Center(child: image)),
            divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLink(devices, Icons.view_compact_sharp, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title:
                                  '$premiseName - $facilityName - $floorName - ${widget.asset.name} - Devices',
                              child: InfraPage(
                                type: TwinInfraType.device,
                                currentView: CurrentView.home,
                                asset: widget.asset,
                              ))),
                    );
                    _pop();
                  }),
                ],
              ),
            ),
            divider(),
            Row(
              mainAxisAlignment: UserSession().isAdmin()
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (UserSession().isAdmin())
                  Tooltip(
                    message: "Roles",
                    child: RolesWidget(
                      currentRoles: rolesSelected,
                      valueChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            rolesSelected = value;
                          });
                        }
                      },
                      isSave: true,
                      iconSize: 20,
                      iconcolor: Colors.green,
                      saveConfirm: (roleValue) {
                        roleValue.removeWhere((element) => element.isEmpty);
                        _updateAsset(widget.asset.copyWith(roles: roleValue));
                      },
                    ),
                  ),
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

  void _updateAsset(Asset assetData) async {
    busy();
    try {
      var res = await UserSession.twin.updateAsset(
          apikey: UserSession().getAuthToken(),
          assetId: widget.asset.id,
          body: AssetInfo(
            name: assetData.name,
            assetModelId: assetData.assetModelId,
            description: assetData.description,
            tags: assetData.tags,
            roles: assetData.roles,
            images: assetData.images,
            location: assetData.location,
            selectedImage: assetData.selectedImage,
            premiseId: assetData.premiseId,
            facilityId: assetData.facilityId,
            floorId: assetData.floorId,
            devices: assetData.devices,
            position: assetData.position,
          ));
      if (validateResponse(res)) {
        await _load();
        Navigator.pop(context);
        alert('Success', 'Asset roles updated successfully');
      }
      refresh();
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }
}
