import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/pages/dashboard/page_infra.dart';
import 'package:twinned/pages/page_child.dart';
import 'package:twinned/pages/widgets/role_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:timeago/timeago.dart' as timeago;

class FloorInfraCard extends StatefulWidget {
  final Floor floor;
  final bool popOnSelect;
  const FloorInfraCard(
      {super.key, required this.floor, this.popOnSelect = false});

  @override
  State<FloorInfraCard> createState() => _FloorInfraCardState();
}

class _FloorInfraCardState extends BaseState<FloorInfraCard> {
  static const Widget missingImage = Icon(
    Icons.question_mark,
    size: 150,
  );

  String premiseName = '';
  String facilityName = '';
  String assets = '';
  String devices = '';
  DeviceData? data;
  String reported = 'reported ?';
  Widget image = missingImage;
  List<String> rolesSelected = [];
  @override
  void initState() {
    if (null != widget.floor.floorPlan && widget.floor.floorPlan!.isNotEmpty) {
      image = UserSession()
          .getImage(widget.floor.domainKey, widget.floor.floorPlan!);
    }
    super.initState();
  }

  @override
  void setup() async {
    rolesSelected = widget.floor.roles!;
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
        premiseId: widget.floor.premiseId);

    if (validateResponse(pRes)) {
      premiseName = pRes.body!.entity!.name;
    }

    var fRes = await UserSession.twin.getFacility(
        apikey: UserSession().getAuthToken(),
        facilityId: widget.floor.facilityId);

    if (validateResponse(fRes)) {
      facilityName = fRes.body!.entity!.name;
    }

    var res = await UserSession.twin.getFloorStats(
        apikey: UserSession().getAuthToken(), floorId: widget.floor.id);

    if (validateResponse(res)) {
      assets = '${res.body!.entity!.assets ?? 0} assets';
      devices = '${res.body!.entity!.devices ?? 0} devices';
    }

    var ddRes = await UserSession.twin.searchRecentDeviceData(
        apikey: UserSession().getAuthToken(),
        floorId: widget.floor.id,
        body: const FilterSearchReq(search: '*', page: 0, size: 1));

    if (validateResponse(ddRes)) {
      if (ddRes.body!.values!.isNotEmpty) {
        data = ddRes.body!.values!.first;
        data = ddRes.body!.values!.first;
        var dt = DateTime.fromMillisecondsSinceEpoch(data!.updatedStamp);
        reported = 'reported ${timeago.format(dt, locale: 'en')}';
      }
    }

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
                              size: 12,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: premiseName,
                                child: Text(
                                  premiseName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                              size: 12,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: facilityName,
                                child: Text(
                                  facilityName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                              size: 12,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: widget.floor.name,
                                child: Text(
                                  widget.floor.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLink(assets, Icons.view_comfy, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title:
                                  '$premiseName - $facilityName - ${widget.floor.name} - Assets',
                              child: InfraPage(
                                type: TwinInfraType.asset,
                                currentView: CurrentView.home,
                                floor: widget.floor,
                              ))),
                    );
                    _pop();
                  }),
                  buildLink(devices, Icons.view_compact_sharp, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title:
                                  '$premiseName - $facilityName - ${widget.floor.name} - Devices',
                              child: InfraPage(
                                type: TwinInfraType.device,
                                currentView: CurrentView.home,
                                floor: widget.floor,
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
                        _updateFloor(widget.floor.copyWith(roles: roleValue));
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

  void _updateFloor(Floor floorData) async {
    busy();
    try {
      var res = await UserSession.twin.updateFloor(
          apikey: UserSession().getAuthToken(),
          floorId: widget.floor.id,
          body: FloorInfo(
            facilityId: floorData.facilityId,
            floorLevel: floorData.floorLevel,
            floorType:
                FloorInfoFloorType.values.byName(floorData.floorType.name),
            name: floorData.name,
            premiseId: floorData.premiseId,
            assets: floorData.assets,
            description: floorData.description,
            floorPlan: floorData.floorPlan,
            location: floorData.location,
            roles: floorData.roles,
            tags: floorData.tags,
          ));
      if (validateResponse(res)) {
        await _load();
        Navigator.pop(context);
        alert('Success', 'Facility roles updated successfully');
      }
      refresh();
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }
}
