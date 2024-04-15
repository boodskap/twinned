import 'dart:convert';

import 'package:colored_json/colored_json.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/widgets/device_component.dart';
import 'package:nocode_commons/widgets/device_view.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/pages/dashboard/page_device_analytics.dart';
import 'package:twinned/pages/dashboard/page_device_history.dart';
import 'package:twinned/pages/dashboard/page_devices.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:eventify/eventify.dart' as event;
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class GridViewPage extends StatefulWidget {
  const GridViewPage({Key? key}) : super(key: key);

  @override
  State<GridViewPage> createState() => _GridViewPageState();
}

class _GridViewPageState extends BaseState<GridViewPage>
    with SingleTickerProviderStateMixin {
  final List<event.Listener> listeners = [];
  late Image bannerImage;
  final List<twin.DeviceData> data = [];
  String search = "*";
  int selectedFilter = -1;
  int? beginStamp;
  int? endStamp;
  String? timeZoneName;

  @override
  void initState() {
    super.initState();

    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );

    listeners.add(BaseState.layoutEvents
        .on(PageEvent.twinMessageReceived.name, this, (e, o) {
      if ('*' == search) {
        setup();
      }
    }));
  }

  @override
  void setup() async {
    debugPrint('loading data...');
    data.clear();

    twin.RangeFilter? filter;

    timeZoneName ??= DateTime.now().timeZoneName;

    switch (selectedFilter) {
      case -1:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.recent, tz: timeZoneName);
        break;
      case 0:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.today, tz: timeZoneName);
        break;
      case 1:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.yesterday, tz: timeZoneName);
        break;
      case 2:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.thisweek, tz: timeZoneName);
        break;
      case 3:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.lastweek, tz: timeZoneName);
        break;
      case 4:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.thismonth, tz: timeZoneName);
        break;
      case 5:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.lastmonth, tz: timeZoneName);
        break;
      case 6:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.thisquarter, tz: timeZoneName);
        break;
      case 7:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.thisyear, tz: timeZoneName);
        break;
      case 8:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.lastyear, tz: timeZoneName);
        break;
      case 9:
        filter = twin.RangeFilter(
            filter: twin.RangeFilterFilter.range,
            beginStamp: beginStamp,
            endStamp: endStamp,
            tz: timeZoneName);
        break;
    }

    var res = await UserSession.twin.searchRecentDeviceData(
        apikey: UserSession().getAuthToken(),
        body: twin.FilterSearchReq(
            search: search, page: 0, size: 100, filter: filter));
    if (validateResponse(res)) {
      data.addAll(res.body!.values!);
    }

    refresh();
  }

  @override
  void dispose() {
    for (event.Listener l in listeners) {
      BaseState.layoutEvents.off(l);
    }
    super.dispose();
  }

  void _changeFilter(int value) async {
    if (value == 9) {
      DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime.now(),
          initialDateRange: DateTimeRange(
            start: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day - 7),
            end: DateTime.now(),
          ),
          builder: (context, child) {
            return Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400.0,
                    maxHeight: 800.0,
                  ),
                  child: child,
                )
              ],
            );
          });
      if (null != picked) {
        selectedFilter = value;
        beginStamp = picked.start.millisecondsSinceEpoch;
        endStamp = picked.end.millisecondsSinceEpoch;
        timeZoneName = picked.start.timeZoneName;
        setup();
      }
    } else {
      selectedFilter = value;
      setup();
    }
  }

  Widget _build(BuildContext context) {
    var rows = _buildTableRows();
    return Column(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const BusyIndicator(),
                  divider(horizontal: true),
                  PopupMenuButton<int>(
                    initialValue: selectedFilter,
                    icon: const FaIcon(FontAwesomeIcons.filter),
                    itemBuilder: (context) {
                      return <PopupMenuEntry<int>>[
                        const PopupMenuItem<int>(
                          value: -1,
                          child: Text('Recent'),
                        ),
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text('Today'),
                        ),
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text('Yesterday'),
                        ),
                        const PopupMenuItem<int>(
                          value: 2,
                          child: Text('This Week'),
                        ),
                        const PopupMenuItem<int>(
                          value: 3,
                          child: Text('Last Week'),
                        ),
                        const PopupMenuItem<int>(
                          value: 4,
                          child: Text('This Month'),
                        ),
                        const PopupMenuItem<int>(
                          value: 5,
                          child: Text('Last Month'),
                        ),
                        const PopupMenuItem<int>(
                          value: 6,
                          child: Text('This Quarter'),
                        ),
                        const PopupMenuItem<int>(
                          value: 7,
                          child: Text('This Year'),
                        ),
                        const PopupMenuItem<int>(
                          value: 8,
                          child: Text('Last Year'),
                        ),
                        const PopupMenuItem<int>(
                          value: 9,
                          child: Text('Date Range'),
                        ),
                      ];
                    },
                    onSelected: (int value) {
                      _changeFilter(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 300,
                      height: 30,
                      child: SearchBar(
                          hintText: 'Search',
                          leading: const Icon(Icons.search),
                          onChanged: (String value) {
                            search = value.isEmpty ? '*' : value;
                            setup();
                          }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 50.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Device Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Device Model',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Hardware ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Reporting Stamp',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Processing Delay',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Events',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Triggers',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
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
                      child: rows[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }

  List<Widget> _buildTableRows() {
    return data.map((data) {
      //debugPrint(jsonEncode(data));
      DateTime reportingStamp =
          DateTime.fromMillisecondsSinceEpoch(data.createdStamp);
      DateTime processedStamp =
          DateTime.fromMillisecondsSinceEpoch(data.updatedStamp);
      Duration difference = processedStamp.difference(reportingStamp);

      String reportingStampDate =
          DateFormat('yyyy/MM/dd h:mm a').format(reportingStamp);

      Color stateColor = Colors.green;
      if (difference.inSeconds <= 45) {
        stateColor = Colors.green;
      } else if (difference.inSeconds <= 59) {
        stateColor = Colors.orange;
      } else {
        stateColor = Colors.red;
      }

      var defList = [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 0, right: 0),
          child: Wrap(children: [
            DeviceComponentView(
              deviceData: data,
              twinned: UserSession.twin,
              authToken: UserSession().getAuthToken(),
              orientation: Axis.horizontal,
            ),
          ]),
        )),
        const Icon(
          Icons.perm_device_info,
          color: Colors.black,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: data.deviceDescription ?? '',
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DeviceHistoryPage(
                              deviceName: data.deviceName ?? '-',
                              deviceId: data.deviceId,
                              modelId: data.modelId,
                              adminMode: true,
                            )),
                  );
                },
                child: Text(
                  data.deviceName ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blueGrey),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Tooltip(
              message: data.modelDescription ?? '',
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DevicesPage(
                              modelId: data.modelId,
                              modelName: data.modelName ?? '',
                            )),
                  );
                },
                child: Text(
                  data.modelName ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blueGrey),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'device id: ${data.deviceId}',
              child:
                  Text(data.hardwareDeviceId, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Tooltip(
              message: reportingStampDate,
              child: Text(timeago.format(reportingStamp, locale: 'en'),
                  overflow: TextOverflow.ellipsis),
            ),
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
            padding: const EdgeInsets.only(left: 60),
            child: Row(
              children: [
                Text('${data.events.length}'),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 63),
            child: Row(
              children: [
                Text('${data.triggers.length}'),
              ],
            ),
          ),
        ),
      ];

      return ExpansionTile(
        title: Row(
          children: defList,
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
                      child: SimpleDeviceView(
                        twinned: UserSession.twin,
                        authToken: UserSession().getAuthToken(),
                        data: data,
                        liveData: true,
                        events: BaseState.layoutEvents,
                        height: 400,
                        topMenuHeight: 35,
                        bottomMenuHeight: 35,
                        onDeviceAnalyticsTapped: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DeviceAnalyticsPage(
                                        data: data,
                                      )));
                        },
                        onDeviceDoubleTapped: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DeviceHistoryPage(
                                      deviceName: data.deviceName ?? '-',
                                      deviceId: data.deviceId,
                                      modelId: data.modelId,
                                      adminMode: true,
                                    )),
                          );
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
                      SingleChildScrollView(
                        child: ColoredJson(data: jsonEncode(data.data)),
                      ),
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
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: 350,
                        child: ListView.builder(
                            itemCount: data.evaluationErrors!.length,
                            itemBuilder: (contex, index) {
                              return Text(data.evaluationErrors![index]);
                            }),
                      ),
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
