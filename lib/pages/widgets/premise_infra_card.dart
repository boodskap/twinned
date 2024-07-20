import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned/pages/dashboard/page_infra.dart';
import 'package:twinned/pages/page_child.dart';
import 'package:twinned/pages/widgets/role_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:timeago/timeago.dart' as timeago;

class PremiseInfraCard extends StatefulWidget {
  final Premise premise;
  final bool popOnSelect;
  const PremiseInfraCard(
      {super.key, required this.premise, this.popOnSelect = false});

  @override
  State<PremiseInfraCard> createState() => _PremiseInfraCardState();
}

class _PremiseInfraCardState extends BaseState<PremiseInfraCard> {
  static const Widget missingImage = Icon(
    Icons.question_mark,
    size: 150,
  );

  String facilities = '';
  String floors = '';
  String assets = '';
  String devices = '';
  DeviceData? data;
  String reported = 'reported ?';
  Widget image = missingImage;
  List<String> rolesSelected = [];
  @override
  void initState() {
    int sId = widget.premise.selectedImage ?? 0;
    sId = sId < 0 ? 0 : sId;
    if (widget.premise.images!.length > sId) {
      image = UserSession()
          .getImage(widget.premise.domainKey, widget.premise.images![sId]);
    }
    super.initState();
  }

  @override
  void setup() async {
    rolesSelected = widget.premise.roles!;
    await _load();
  }

  Future _load() async {
    var res = await UserSession.twin.getPremiseStats(
        apikey: UserSession().getAuthToken(), premiseId: widget.premise.id);
    if (validateResponse(res)) {
      facilities = '${res.body!.entity!.facilities ?? 0} facilities';
      floors = '${res.body!.entity!.floors ?? 0} floors';
      assets = '${res.body!.entity!.assets ?? 0} assets';
      devices = '${res.body!.entity!.devices ?? 0} devices';
    }
    var ddRes = await UserSession.twin.searchRecentDeviceData(
        apikey: UserSession().getAuthToken(),
        premiseId: widget.premise.id,
        body: const FilterSearchReq(search: '*', page: 0, size: 1));
    if (validateResponse(ddRes)) {
      if (ddRes.body!.values!.isNotEmpty) {
        data = ddRes.body!.values!.first;

        var dt = DateTime.fromMillisecondsSinceEpoch(data!.updatedStamp);
        reported = 'reported ${timeago.format(dt, locale: 'en')}';
      }
    }
    refresh();
  }

  void _pop() {
    if (widget.popOnSelect) {
      Navigator.pop(context);
    }
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
                    children: [
                      const Icon(
                        Icons.home,
                        color: Colors.green,
                        size: 25,
                      ),
                      divider(horizontal: true, width: 2),
                      Expanded(
                        child: Tooltip(
                          message: widget.premise.name,
                          child: Text(
                            widget.premise.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                overflow: TextOverflow.ellipsis),
                          ),
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
                  buildLink(facilities, Icons.business, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title: '${widget.premise.name} - Facilities',
                              child: InfraPage(
                                type: TwinInfraType.facility,
                                currentView: CurrentView.home,
                                premise: widget.premise,
                              ))),
                    );
                    _pop();
                  }),
                  buildLink(floors, Icons.cabin, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title: '${widget.premise.name} - Floors',
                              child: InfraPage(
                                type: TwinInfraType.floor,
                                currentView: CurrentView.home,
                                premise: widget.premise,
                              ))),
                    );
                    _pop();
                  }),
                  buildLink(assets, Icons.view_comfy, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title: '${widget.premise.name} - Assets',
                              child: InfraPage(
                                type: TwinInfraType.asset,
                                currentView: CurrentView.home,
                                premise: widget.premise,
                              ))),
                    );
                    _pop();
                  }),
                  buildLink(devices, Icons.view_compact_sharp, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChildPage(
                              title: '${widget.premise.name} - Devices',
                              child: InfraPage(
                                type: TwinInfraType.device,
                                currentView: CurrentView.home,
                                premise: widget.premise,
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
                        // print(widget.premise.name);
                        // print(roleValue);
                        // print(widget.premise.copyWith(roles: roleValue));

                        _updatePremise(
                            widget.premise.copyWith(roles: roleValue));
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

  void _updatePremise(Premise premiseData) async {
    busy();
    try {
      var res = await UserSession.twin.updatePremise(
          apikey: UserSession().getAuthToken(),
          premiseId: widget.premise.id,
          // body:PremiseInfo(name: premiseData.name)
          body: PremiseInfo(
              name: premiseData.name,
              description: premiseData.description,
              tags: premiseData.tags,
              roles: premiseData.roles,
              images: premiseData.images,
              location: premiseData.location,
              selectedImage: premiseData.selectedImage));
      if (validateResponse(res)) {
        await _load();
        Navigator.pop(context);
        alert('Success', 'Premise roles updated successfully');
      }
      refresh();
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }
}
