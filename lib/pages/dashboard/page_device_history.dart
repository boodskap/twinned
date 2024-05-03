import 'dart:convert';

import 'package:colored_json/colored_json.dart';
import 'package:eventify/eventify.dart' as event;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/ui.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:nocode_commons/widgets/default_deviceview.dart';
import 'package:nocode_commons/widgets/device_view.dart';
import 'package:twinned/pages/dashboard/page_device_analytics.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:timeago/timeago.dart' as timeago;
import 'package:nocode_commons/util/nocode_utils.dart';

class DeviceHistoryPage extends StatefulWidget {
  final String deviceName;
  final String deviceId;
  final String modelId;
  final bool adminMode;
  const DeviceHistoryPage(
      {Key? key,
      required this.deviceName,
      required this.deviceId,
      required this.modelId,
      required this.adminMode})
      : super(key: key);

  @override
  State<DeviceHistoryPage> createState() => _DeviceHistoryPageState();
}

class _DeviceHistoryPageState extends BaseState<DeviceHistoryPage>
    with SingleTickerProviderStateMixin {
  twin.DeviceModel? deviceModel;
  final List<event.Listener> listeners = [];
  late Widget bannerImage;
  final List<twin.DeviceData> data = [];
  final List<Widget> columns = [];
  final List<String> dataColumns = [];
  String search = "*";
  int selectedFilter = -1;
  int? beginStamp;
  int? endStamp;
  String? timeZoneName;
  @override
  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (null != twinSysInfo && twinSysInfo!.bannerImage!.isNotEmpty) {
      bannerImage = UserSession()
          .getImage(domainKey, twinSysInfo!.bannerImage!, fit: BoxFit.cover);
    } else {
      bannerImage = Image.asset(
        'assets/images/ldashboard_banner.png',
        fit: BoxFit.cover,
      );
    }

    listeners.add(BaseState.layoutEvents
        .on(PageEvent.twinMessageReceived.name, this, (e, o) {
      if (e.eventData == widget.deviceId) {
        if ('*' == search) {
          setup();
        }
      }
    }));

    var list = [
      const Expanded(
        child: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.access_time),
            Text(
              'Last Reported',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      if (widget.adminMode)
        const Expanded(
          child: Text(
            'Proc Speed',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      if (widget.adminMode)
        const Expanded(
          child: Text(
            'Events',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      if (widget.adminMode)
        const Expanded(
          child: Text(
            'Triggers',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
    ];

    columns.addAll(list);
  }

  @override
  void setup() async {
    await _load();
  }

  Future _load() async {
    if (loading) return;

    loading = true;

    await execute(() async {
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

      var res = await UserSession.twin.searchDeviceHistoryData(
          apikey: UserSession().getAuthToken(),
          deviceId: widget.deviceId,
          body: twin.FilterSearchReq(
              search: search, filter: filter, page: 0, size: 100));
      if (validateResponse(res)) {
        data.addAll(res.body!.values!);
      }

      if (null == deviceModel) {
        var mRes = await UserSession.twin.getDeviceModel(
            apikey: UserSession().getAuthToken(), modelId: widget.modelId);
        if (validateResponse(mRes)) {
          deviceModel = mRes.body!.entity;
          var fields = NoCodeUtils.getSortedFields(deviceModel!);
          for (var p in fields) {
            dataColumns.add(p);
            columns.add(
              Expanded(
                child: Text(
                  NoCodeUtils.getParameterLabel(p, deviceModel!),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 18),
                ),
              ),
            );
          }
        }
      }

      refresh();
    });

    loading = false;
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = _buildTableRows();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F65AD),
        centerTitle: true,
        leading: const BackButton(
          color: Color(0XFFFFFFFF),
        ),
        title: Text(
          '${widget.deviceName} - History',
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
            height: 100,
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
                    const BusyIndicator(),
                    divider(horizontal: true),
                    IconButton(
                        onPressed: () async {
                          search = '*';
                          selectedFilter = -1;
                          await _load();
                        },
                        icon: const Icon(Icons.refresh)),
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
                    itemCount: children.length,
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
                        child: children[index],
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
    if (data.isEmpty) {
      return [
        Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Text(loading ? 'Loading...' : 'No data')
          ],
        )
      ];
    }

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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Tooltip(
                message: reportingStamp.toString(),
                child: Text(timeago.format(reportingStamp, locale: 'en'))),
          ),
        ),
        if (widget.adminMode)
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
        if (widget.adminMode)
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
        if (widget.adminMode)
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
                Text(
                  '${dynValue.toString()} ${NoCodeUtils.getParameterUnit(dataColumns[i], deviceModel!)}',
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
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
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: DefaultDeviceView(
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
                if (widget.adminMode)
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
                if (widget.adminMode && data.evaluationErrors!.isEmpty)
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
                if (widget.adminMode && data.evaluationErrors!.isNotEmpty)
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
