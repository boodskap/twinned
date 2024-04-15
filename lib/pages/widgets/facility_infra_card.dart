import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/pages/dashboard/page_infra.dart';
import 'package:twinned/pages/page_child.dart';
import 'package:twinned/pages/widgets/role_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:timeago/timeago.dart' as timeago;

class FacilityInfraCard extends StatefulWidget {
  final Facility facility;
  final bool popOnSelect;
  const FacilityInfraCard(
      {super.key, required this.facility, this.popOnSelect = false});

  @override
  State<FacilityInfraCard> createState() => _FacilityInfraCardState();
}

class _FacilityInfraCardState extends BaseState<FacilityInfraCard> {
  static const Widget missingImage = Icon(
    Icons.question_mark,
    size: 150,
  );

  String premiseName = '';
  String floors = '';
  String assets = '';
  String devices = '';
  DeviceData? data;
  String reported = 'reported ?';
  Widget image = missingImage;
  List<String> rolesSelected = [];
  @override
  void initState() {
    int sId = widget.facility.selectedImage ?? 0;
    sId = sId < 0 ? 0 : sId;
    if (widget.facility.images!.length > sId) {
      image = UserSession()
          .getImage(widget.facility.domainKey, widget.facility.images![sId]);
    }
    super.initState();
  }

  @override
  void setup() async {
    rolesSelected = widget.facility.roles!;
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
        premiseId: widget.facility.premiseId);

    if (validateResponse(pRes)) {
      premiseName = pRes.body!.entity!.name;
    }

    var res = await UserSession.twin.getFacilityStats(
        apikey: UserSession().getAuthToken(), facilityId: widget.facility.id);

    if (validateResponse(res)) {
      floors = '${res.body!.entity!.floors ?? 0} floors';
      assets = '${res.body!.entity!.assets ?? 0} assets';
      devices = '${res.body!.entity!.devices ?? 0} devices';
    }

    var ddRes = await UserSession.twin.searchRecentDeviceData(
        apikey: UserSession().getAuthToken(),
        facilityId: widget.facility.id,
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
                              size: 16,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: premiseName,
                                child: Text(
                                  premiseName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                              size: 16,
                            ),
                            divider(horizontal: true, width: 2),
                            Expanded(
                              child: Tooltip(
                                message: widget.facility.name,
                                child: Text(
                                  widget.facility.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                  buildLink(floors, Icons.cabin, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title:
                                  '$premiseName - ${widget.facility.name} - Floors',
                              child: InfraPage(
                                type: TwinInfraType.floor,
                                currentView: CurrentView.home,
                                facility: widget.facility,
                              ))),
                    );
                    _pop();
                  }),
                  buildLink(assets, Icons.view_comfy, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title:
                                  '$premiseName - ${widget.facility.name} - Assets',
                              child: InfraPage(
                                type: TwinInfraType.asset,
                                currentView: CurrentView.home,
                                facility: widget.facility,
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
                                  '$premiseName - ${widget.facility.name} - Devices',
                              child: InfraPage(
                                type: TwinInfraType.device,
                                currentView: CurrentView.home,
                                facility: widget.facility,
                              ))),
                    );
                    _pop();
                  }),
                ],
              ),
            ),
            divider(),
            Row(
              mainAxisAlignment: UserSession().isAdmin()?  MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
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
                     iconcolor:Colors.green,
                    saveConfirm: (roleValue) {
                      roleValue.removeWhere((element) => element.isEmpty);
                      _updateFacility(
                          widget.facility.copyWith(roles: roleValue));
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

  void _updateFacility(Facility faciltyData) async {
    busy();
    try {
      var res = await UserSession.twin.updateFacility(
          apikey: UserSession().getAuthToken(),
          facilityId: widget.facility.id,
          body: FacilityInfo(
              premiseId: faciltyData.premiseId,
              images: faciltyData.images,
              description: faciltyData.description,
              selectedImage: faciltyData.selectedImage,
              tags: faciltyData.tags,
              location: faciltyData.location,
              roles: faciltyData.roles,
              settings: faciltyData.settings,
              name: faciltyData.name));
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
