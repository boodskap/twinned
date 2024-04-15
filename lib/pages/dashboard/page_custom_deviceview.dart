import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

class myDeviceView extends StatefulWidget {
  const myDeviceView({super.key});

  @override
  State<myDeviceView> createState() => _myDeviceViewState();
}

class _myDeviceViewState extends State<myDeviceView> {
  @override
  Widget build(BuildContext context) {
    return FormGrids(
        twinned: UserSession.twin, authtoken: UserSession().getAuthToken());
  }
}

class FormGrids extends StatefulWidget {
  final twin.Twinned twinned;
  final String authtoken;

  const FormGrids({
    required this.twinned,
    Key? key,
    required this.authtoken,
  }) : super(key: key);
  @override
  State<FormGrids> createState() => _FormGridsState();
}



class _FormGridsState extends State<FormGrids> {
  List<twin.DeviceView> entities = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    var res = await UserSession.twin.listDeviceViews(
      apikey: widget.authtoken,
      body: const twin.ListReq(page: 0, size: 10000),
    );
    // print(res.body!.values);

    for (twin.DeviceView e in res.body!.values!) {
      entities.add(e);
    }
    setState(() {
      entities = entities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: entities.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return FinalDevView(
            authtoken: widget.authtoken,
            twinned: widget.twinned,
            myDeviceView: entities[index]);
      },
    );
  }
}




class FinalDevView extends StatefulWidget {
  final twin.Twinned twinned;
  final twin.DeviceView myDeviceView;
  final String authtoken;

  const FinalDevView({
    required this.twinned,
    required this.myDeviceView,
    Key? key,
    required this.authtoken,
  }) : super(key: key);

  @override
  State<FinalDevView> createState() => _FinalDevViewState();
}

class _FinalDevViewState extends BaseState<FinalDevView> {
  List<Map<String, dynamic>> alarmImages = [];
  List<Map<String, dynamic>> selectedAlarmImages = [];
  Map<String, dynamic> deviceModel = {};
  List<Map<String, dynamic>> displays = [];
  List<Map<String, dynamic>> selectedDisplays = [];

  List<Map<String, dynamic>> topStorage = [];
  List<Map<String, dynamic>> bottomStorage = [];
  List<Map<String, dynamic>> rightStorage = [];
  List<Map<String, dynamic>> leftStorage = [];
  List<Map<String, dynamic>> centerStorage = [];

  final TextEditingController _topMenuController =
      TextEditingController(text: 50.toString());
  final TextEditingController _bottomMenuController =
      TextEditingController(text: 50.toString());
  final TextEditingController _leftMenuController =
      TextEditingController(text: 50.toString());
  final TextEditingController _rightMenuController =
      TextEditingController(text: 50.toString());

  @override
  void initState() {
    super.initState();
    loadDisplay();
    loadAlarm();
    loadDecive();

    _topMenuController.text = widget.myDeviceView.topHeight! > 0
        ? widget.myDeviceView.topHeight.toString()
        : 40.toString();
    _bottomMenuController.text = widget.myDeviceView.bottomHeight! > 0
        ? widget.myDeviceView.bottomHeight.toString()
        : 40.toString();
    _leftMenuController.text = widget.myDeviceView.leftWidth! > 0
        ? widget.myDeviceView.leftWidth.toString()
        : 40.toString();
    _rightMenuController.text = widget.myDeviceView.rightWidth! > 0
        ? widget.myDeviceView.rightWidth.toString()
        : 40.toString();
    _height = widget.myDeviceView.height!.toDouble();
    _width = widget.myDeviceView.width!.toDouble();

    List<Map<String, dynamic>>? top =
        widget.myDeviceView.top?.map((e) => e.toJson()).toList();
    topStorage.addAll(top!);

    List<Map<String, dynamic>>? bot =
        widget.myDeviceView.bottom?.map((e) => e.toJson()).toList();
    bottomStorage.addAll(bot!);

    List<Map<String, dynamic>>? lef =
        widget.myDeviceView.left?.map((e) => e.toJson()).toList();
    leftStorage.addAll(lef!);

    List<Map<String, dynamic>>? rig =
        widget.myDeviceView.right?.map((e) => e.toJson()).toList();
    rightStorage.addAll(rig!);

    List<Map<String, dynamic>>? cen =
        widget.myDeviceView.positioned?.map((e) => e.toJson()).toList();
    centerStorage.addAll(cen!);
  }

  void loadAlarm() async {
    alarmImages = [];
    var res = await widget.twinned.listAlarms(
        apikey: widget.authtoken, body: const twin.ListReq(page: 0, size: 100));
    var myres = res.body?.values;
    setState(() {
      for (int i = 0; i < myres!.length; i++) {
        var topcheck = topStorage.firstWhere(
            (element) => element['id'] == myres[i].id,
            orElse: () => {});
        var botcheck = bottomStorage.firstWhere(
            (element) => element['id'] == myres[i].id,
            orElse: () => {});
        var rightcheck = rightStorage.firstWhere(
            (element) => element['id'] == myres[i].id,
            orElse: () => {});
        var leftcheck = leftStorage.firstWhere(
            (element) => element['id'] == myres[i].id,
            orElse: () => {});
        var centercheck = centerStorage.firstWhere(
            (element) => element['view']['id'] == myres[i].id,
            orElse: () => {});
        if (topcheck.isEmpty &&
            botcheck.isEmpty &&
            leftcheck.isEmpty &&
            rightcheck.isEmpty &&
            centercheck.isEmpty) {
          if (myres[i].stateIcons!.isEmpty) {
            alarmImages.add({
              'name': myres[i].name,
              'id': myres[i].id,
              'state': -1,
              'img': 'images/new-alarm.png',
              'type': 'ALARM',
              'height': 40,
              'width': 40
            });
            // print(alarmImages[i]['img']);
          } else {
            alarmImages.add({
              'name': myres[i].name,
              'id': myres[i].id,
              'state': myres[i].state,
              'img': myres[i].stateIcons![0],
              'type': 'ALARM',
              'domainkey': myres[i].domainKey,
              'height': 40,
              'width': 40
            });
            // print(alarmImages[i]['img']);
          }
        }
        if (myres[i].stateIcons!.isEmpty) {
          selectedAlarmImages.add({
            'name': myres[i].name,
            'id': myres[i].id,
            'state': -1,
            'img': 'images/new-alarm.png',
            'type': 'ALARM',
            'height': 40,
            'width': 40
          });
          // print(alarmImages[i]['img']);
        } else {
          selectedAlarmImages.add({
            'name': myres[i].name,
            'id': myres[i].id,
            'state': myres[i].state,
            'img': myres[i].stateIcons![0],
            'type': 'ALARM',
            'domainkey': myres[i].domainKey,
            'height': 40,
            'width': 40
          });
          // print(alarmImages[i]['img']);
        }
      }
    });
  }

  void loadDecive() async {
    try {
      var res = await widget.twinned.getDeviceModel(
        modelId: widget.myDeviceView.modelId,
        apikey: widget.authtoken,
      );
      setState(() {
        var myres = res.body!.entity!;
        deviceModel['img'] =
            myres.images!.isNotEmpty ? myres.images![0] : 'EMPTY';
        deviceModel['domainkey'] = myres.domainKey;
        deviceModel['type'] = 'DEVICE';
        deviceModel['id'] = myres.id;
      });
    } catch (e, s) {
      debugPrint(s.toString());
    }
  }

  void loadDisplay() async {
    try {
      displays = [];
      var res = await widget.twinned.listDisplays(
          apikey: widget.authtoken,
          body: const twin.ListReq(page: 0, size: 1000));
      var myres = res.body?.values;
      // print(myres);
      for (int i = 0; i < myres!.length; i++) {
        var topcheck = topStorage.firstWhere(
            (element) => element['id'] == myres[i].id,
            orElse: () => {});
        var botcheck = bottomStorage.firstWhere(
            (element) => element['id'] == myres[i].id,
            orElse: () => {});
        var rightcheck = rightStorage.firstWhere(
            (element) => element['id'] == myres[i].id,
            orElse: () => {});
        var leftcheck = leftStorage.firstWhere(
            (element) => element['id'] == myres[i].id,
            orElse: () => {});
        var centercheck = centerStorage.firstWhere(
            (element) => element['view']['id'] == myres[i].id,
            orElse: () => {});
        if (topcheck.isEmpty &&
            botcheck.isEmpty &&
            leftcheck.isEmpty &&
            rightcheck.isEmpty &&
            centercheck.isEmpty) {
          if (myres[i].conditions.isNotEmpty) {
            displays.add({
              'displayname': myres[i].name,
              'id': myres[i].id,
              // 'type': twinned.DisplayableType.display,
              'type': 'DISPLAY',
              'height': myres[i].conditions[0].height,
              'width': myres[i].conditions[0].width,
              'conditions': myres[i].conditions[0],
              'bgColor': myres[i].conditions[0].bgColor,
              'value': myres[i].conditions[0].value,
              'borderColor': myres[i].conditions[0].bordorColor,
              'fontSize': myres[i].conditions[0].fontSize
            });
          }
        } else {
          if (myres[i].conditions.isNotEmpty) {
            selectedDisplays.add({
              'displayname': myres[i].name,
              'id': myres[i].id,
              // 'type': twinned.DisplayableType.display,
              'type': 'DISPLAY',
              'height': myres[i].conditions[0].height,
              'width': myres[i].conditions[0].width,
              'conditions': myres[i].conditions[0],
              'bgColor': myres[i].conditions[0].bgColor,
              'value': myres[i].conditions[0].value,
              'borderColor': myres[i].conditions[0].bordorColor,
              'fontSize': myres[i].conditions[0].fontSize
            });
          }
        }
      }
      // displays = displays;
      // print(displays.length);
    } catch (e, s) {
      debugPrint(s.toString());
    }
  }

  Widget buildAlarm(String id, double h, double w) {
    var obj = selectedAlarmImages.firstWhere(
      (element) => element['id'] == id,
      orElse: () => {},
    );
    return Tooltip(
        message: obj['name'],
        child: obj.containsKey('domainkey')
            ? Image.network(
                twinImageUrl(widget.twinned.client.baseUrl.toString(),
                    obj['domainkey'], obj['img']),
                height: h,
                width: w,
              )
            : Image.asset(
                obj['img'],
                height: h,
                width: w,
              ));
  }

  Widget buildDisplay(String id, double h, double w) {
    var obj = selectedDisplays.firstWhere((element) => element['id'] == id,
        orElse: () => {});
    var cons = obj.isNotEmpty ? obj['conditions'] : null;
    return obj.isNotEmpty
        ? Tooltip(
            message: obj['displayname'],
            child: Container(
              height: h,
              width: w,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Color(
                  cons.bordorColor!,
                )),
                borderRadius: BorderRadius.all(Radius.elliptical(h, w)),
                color: Color(cons.bgColor!),
              ),
              child: Center(
                  child: Text(
                cons.value!,
                style: TextStyle(fontSize: cons.fontSize),
              )),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Card(
          color: Colors.transparent,
          elevation: 5,
          child: deviceModel.isNotEmpty
              ? Container(
                  height: _getHeight(),
                  width: _getWidth(),
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      //Center Side
                      Center(
                        child: Container(
                          color: Colors.white,
                          child: Stack(alignment: Alignment.center, children: [
                            Center(
                              child: deviceModel['img'] != 'EMPTY'
                                  ? Image.network(
                                      twinImageUrl(
                                        widget.twinned.client.baseUrl.toString(),
                                        deviceModel['domainkey'],
                                        deviceModel['img'],
                                      ),
                                      height: _height - 150,
                                      width: _width - 150,
                                    )
                                  : const Text('Device Image Not Found!'),
                            ),
                            if (centerStorage.isNotEmpty)
                              ...centerStorage.asMap().entries.map(
                                    (entry) => Positioned(
                                      top: entry.value['top'],
                                      left: entry.value['left'],
                                      child:
                                          entry.value['view']['type'] == 'ALARM'
                                              ? buildAlarm(
                                                  entry.value['view']['id'],
                                                  entry.value['view']['height'],
                                                  entry.value['view']['width'])
                                              : buildDisplay(
                                                  entry.value['view']['id'],
                                                  entry.value['view']['height'],
                                                  entry.value['view']['width']),
                                    ),
                                  )
                          ]),
                        ),
                      ),
                      // Right Side
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: double.tryParse(_rightMenuController.text),
                          color: Colors.white,
                          child: Center(
                            child: rightStorage.isNotEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: rightStorage
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) =>
                                              entry.value['type'] == 'ALARM'
                                                  ? buildAlarm(
                                                      entry.value['id'],
                                                      entry.value['height'],
                                                      entry.value['width'])
                                                  : buildDisplay(
                                                      entry.value['id'],
                                                      entry.value['height'],
                                                      entry.value['width']),
                                        )
                                        .toList())
                                : Container(),
                          ),
                        ),
                      ),
                      // Left Side
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: double.tryParse(_leftMenuController.text),
                          color: Colors.white,
                          child: Center(
                            child: leftStorage.isNotEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: leftStorage
                                        .asMap()
                                        .entries
                                        .map((entry) =>
                                            entry.value['type'] == 'ALARM'
                                                ? buildAlarm(
                                                    entry.value['id'],
                                                    entry.value['height'],
                                                    entry.value['width'])
                                                : buildDisplay(
                                                    entry.value['id'],
                                                    entry.value['height'],
                                                    entry.value['width']))
                                        .toList())
                                : Container(),
                          ),
                        ),
                      ),
                      // Top Side
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: double.tryParse(_topMenuController.text),
                          color: Colors.white,
                          child: Center(
                            child: topStorage.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: topStorage
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) =>
                                              entry.value['type'] == 'ALARM'
                                                  ? buildAlarm(
                                                      entry.value['id'],
                                                      entry.value['height'],
                                                      entry.value['width'])
                                                  : buildDisplay(
                                                      entry.value['id'],
                                                      entry.value['height'],
                                                      entry.value['width']),
                                        )
                                        .toList())
                                : Container(),
                          ),
                        ),
                      ),
                      // Bottom Side
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: double.tryParse(_bottomMenuController.text),
                          color: Colors.white,
                          child: Center(
                            child: bottomStorage.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: bottomStorage
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) =>
                                              entry.value['type'] == 'ALARM'
                                                  ? buildAlarm(
                                                      entry.value['id'],
                                                      entry.value['height'],
                                                      entry.value['width'])
                                                  : buildDisplay(
                                                      entry.value['id'],
                                                      entry.value['height'],
                                                      entry.value['width']),
                                        )
                                        .toList())
                                : Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const CircularProgressIndicator(
                  color: Colors.redAccent,
                ),
        ),
      ),
    );
  }

  double _getHeight() {
    return _height;
  }

  double _getWidth() {
    return _width;
  }

  // double _getInnerHeight() {
  //   return _innerHeight;
  // }

  // double _getInnerWidth() {
  //   return _innerWidth;
  // }

  double _height = 500;
  double _width = 500;
  // final double _innerHeight = 50;
  // final double _innerWidth = 50;

  @override
  void setup() {}
}
