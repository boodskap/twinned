import 'dart:convert';

import 'package:colored_json/colored_json.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/ui.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/widgets/default_deviceview.dart';
import 'package:nocode_commons/widgets/device_view.dart';
import 'package:twinned/pages/dashboard/page_device_analytics.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:timeago/timeago.dart' as timeago;

class DevicesPage extends StatefulWidget {
  final String modelId;
  final String modelName;
  const DevicesPage({Key? key, required this.modelId, required this.modelName})
      : super(key: key);

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends BaseState<DevicesPage>
    with SingleTickerProviderStateMixin {
  twin.DeviceModel? deviceModel;
  late Image bannerImage;
  final List<twin.DeviceData> data = [];
  final List<Widget> columns = [];
  final List<String> dataColumns = [];
  String search = "*";

  bool sortModelIdAscending = true;
  bool sortDeviceIdAscending = true;
  bool sortAscending = true;

  @override
  void initState() {
    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );

    var list = [
      const Expanded(
        child: Text(
          'Last Reported',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const Expanded(
        child: Text(
          'Device',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const Expanded(
        child: Text(
          'Processing Delay',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const Expanded(
        child: Text(
          'Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const Expanded(
        child: Text(
          'Triggers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ];

    columns.addAll(list);

    super.initState();
  }

  @override
  void setup() async {
    await execute(() async {
      data.clear();
      dataColumns.clear();

      var mRes = await UserSession.twin.getDeviceModel(
          apikey: UserSession().getAuthToken(), modelId: widget.modelId);
      if (validateResponse(mRes)) {
        deviceModel = mRes.body!.entity;
        int i = 0;
        for (var p in deviceModel!.parameters) {
          if (++i > 6) break;
          dataColumns.add(p.name);
          columns.add(
            Expanded(
              child: Text(
                p.label ?? p.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      }

      var res = await UserSession.twin.searchRecentDeviceData(
          apikey: UserSession().getAuthToken(),
          modelId: widget.modelId,
          body: twin.FilterSearchReq(search: search, page: 0, size: 100));
      if (validateResponse(res)) {
        data.addAll(res.body!.values!);
      }

      if (null == deviceModel) {}

      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F65AD),
        centerTitle: true,
        leading: const BackButton(
          color: Color(0XFFFFFFFF),
        ),
        title: Text(
          '${widget.modelName} - Devices',
          style: const TextStyle(
            color: Color(0XFFFFFFFF),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color(0XFFFFFFFF),
            ),
            onPressed: () {
              UI().logout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: bannerImage,
          ),
          Expanded(
            flex: 20,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 300,
                        height: 30,
                        child: SearchBar(
                            hintText: 'Search',
                            leading:
                                const FaIcon(FontAwesomeIcons.magnifyingGlass),
                            onChanged: (String value) {
                              search = value.isEmpty ? '*' : value;
                              setup();
                            }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  child: Row(
                    children: columns,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _buildTableRows().length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: _buildTableRows()[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTableRows() {
    return data.map((data) {
      //debugPrint(jsonEncode(data));
      DateTime reportingStamp =
          DateTime.fromMillisecondsSinceEpoch(data.createdStamp);
      DateTime processedStamp =
          DateTime.fromMillisecondsSinceEpoch(data.updatedStamp);
      Duration difference = processedStamp.difference(reportingStamp);

      Color stateColor = Colors.green;
      if (difference.inSeconds <= 45) {
        stateColor = Colors.green;
      } else if (difference.inSeconds <= 59) {
        stateColor = Colors.orange;
      } else {
        stateColor = Colors.red;
      }

      final List<Widget> children = [
        const Icon(
          Icons.device_thermostat,
          color: Colors.black,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Tooltip(
                message: reportingStamp.toString(),
                child: Text(timeago.format(reportingStamp, locale: 'en'))),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text('${data.deviceName}'),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 75),
            child: Tooltip(
              message: () {
                if (difference.inSeconds < 1) {
                  return 'took ${difference.inMilliseconds} millis';
                }
                return 'took ${difference.inSeconds} seconds';
              }(),
              child: Row(
                children: [
                  const Text('', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  CircleAvatar(
                    backgroundColor: stateColor,
                    radius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              children: [
                Text('${data.events.length}'),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              children: [
                Text('${data.triggers.length}'),
              ],
            ),
          ),
        ),
      ];

      Map<String, dynamic> map = data.data as Map<String, dynamic>;

      for (int i = 0; i < dataColumns.length; i++) {
        var dynValue = map[dataColumns[i]] ?? '-';
        children.add(Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              children: [
                Text(dynValue.toString()),
              ],
            ),
          ),
        ));
      }

      return ExpansionTile(
        title: Row(
          children: children,
        ),
        children: [
          SizedBox(
            height: 500,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: double.maxFinite,
                    // color: Colors.red,
                    child: Center(
                      child: DefaultDeviceView(
                        deviceData: data,
                        deviceId: data.deviceId,
                        twinned: UserSession.twin,
                        authToken: UserSession().getAuthToken(),
                        onDeviceDoubleTapped: (dd) async {},
                        onDeviceAnalyticsTapped: (dd) async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DeviceAnalyticsPage(
                                        data: data,
                                      )));
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ColoredJson(data: jsonEncode(data.data)),
                    ],
                  ),
                ),
                if (data.evaluationErrors!.isEmpty)
                  const Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('No Errors'),
                      ],
                    ),
                  ),
                if (data.evaluationErrors!.isNotEmpty)
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: ListView.builder(
                          itemCount: data.evaluationErrors!.length,
                          itemBuilder: (contex, index) {
                            return Text(data.evaluationErrors![index]);
                          }),
                    ),
                  ),
              ],
            ),
          )
        ],
      );
    }).toList();
  }
}
