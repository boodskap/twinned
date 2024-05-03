import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:nocode_commons/widgets/device_component.dart';
import 'package:twinned/pages/dashboard/page_device_history.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:data_table_2/data_table_2.dart';
import 'package:twinned_widgets/twinned_widgets.dart' as widgets;

class DataGridSnippet extends StatefulWidget {
  const DataGridSnippet({super.key});

  @override
  State<DataGridSnippet> createState() => DataGridSnippetState();
}

class DataGridSnippetState extends BaseState<DataGridSnippet> {
  final List<DeviceData> _data = [];
  final Map<String, DeviceModel> _models = {};

  @override
  void setup() {
    load();
  }

  Future load({String search = '*', int page = 0, int size = 1000}) async {
    if (loading) return;
    loading = true;

    if (search.trim().isEmpty) {
      search = '*';
    }

    await execute(() async {
      _data.clear();
      _models.clear();

      var dRes = await UserSession.twin.searchRecentDeviceData(
          apikey: UserSession().getAuthToken(),
          body: FilterSearchReq(search: search, page: page, size: size));

      if (validateResponse(dRes)) {
        _data.addAll(dRes.body!.values!);

        List<String> modelIds = [];

        for (DeviceData dd in _data) {
          if (modelIds.contains(dd.modelId)) continue;
          modelIds.add(dd.modelId);
        }

        var mRes = await UserSession.twin.getDeviceModels(
            apikey: UserSession().getAuthToken(), body: GetReq(ids: modelIds));

        if (validateResponse(mRes)) {
          for (var deviceModel in mRes.body!.values!) {
            _models[deviceModel.id] = deviceModel;
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  void _padding(List<Widget> children) {
    if (children.isNotEmpty) {
      if (children.last is! SizedBox) {
        children.add(divider(horizontal: true, width: 24));
      }
    }
  }

  Widget _buildTable() {
    List<DataColumn2> columns = [];
    List<DataRow2> rows = [];

    columns.addAll([
      const DataColumn2(
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.castle),
            Text(
              'Asset',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      const DataColumn2(
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.blur_on_sharp),
            Text(
              'Device',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      const DataColumn2(
        label: Wrap(
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
      const DataColumn2(
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.location_pin),
            Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      DataColumn2(
          label: const Center(
              child: Wrap(
            spacing: 4.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.menu),
              Text(
                'Sensor Data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          )),
          fixedWidth: MediaQuery.of(context).size.width / 2),
    ]);

    for (var dd in _data) {
      var dT = DateTime.fromMillisecondsSinceEpoch(dd.updatedStamp);
      List<Widget> children = [];
      Map<String, dynamic> dynData = dd.data as Map<String, dynamic>;
      DeviceModel deviceModel = _models[dd.modelId]!;
      List<String> fields = NoCodeUtils.getSortedFields(deviceModel);
      for (String field in fields) {
        widgets.SensorWidgetType type =
            NoCodeUtils.getSensorWidgetType(field, _models[dd.modelId]!);
        if (type == widgets.SensorWidgetType.none) {
          String iconId = NoCodeUtils.getParameterIcon(field, deviceModel);
          _padding(children);
          children.add(Column(
            children: [
              Text(
                NoCodeUtils.getParameterLabel(field, deviceModel),
                style: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold),
              ),
              if (iconId.isNotEmpty) divider(),
              if (iconId.isNotEmpty)
                SizedBox(
                    width: 28,
                    height: 28,
                    child: UserSession().getImage(dd.domainKey, iconId)),
              divider(),
              Text(
                '${dynData[field] ?? '-'} ${NoCodeUtils.getParameterUnit(field, deviceModel)}',
                style: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ));
          children.add(divider(horizontal: true, width: 24));
        } else {
          Parameter? parameter =
              NoCodeUtils.getParameter(field, _models[dd.modelId]!);
          children.add(ConstrainedBox(
              constraints: const BoxConstraints(
                  minWidth: 80, minHeight: 160, maxWidth: 80, maxHeight: 160),
              child: widgets.SensorWidget(
                parameter: parameter!,
                deviceData: dd,
                deviceModel: deviceModel,
                tiny: true,
              )));
        }
      }

      rows.add(DataRow2(cells: [
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: Text(
                dd.asset ?? '-',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold),
              ),
            ),
            divider(),
            DeviceComponentView(
                twinned: UserSession.twin,
                authToken: UserSession().getAuthToken(),
                deviceData: dd),
          ],
        )),
        DataCell(Wrap(
          spacing: 4.0,
          children: [
            Wrap(
              children: [
                Tooltip(
                  message: 'Device Serial#',
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeviceHistoryPage(
                                  deviceName: dd.deviceName ?? '-',
                                  deviceId: dd.deviceId,
                                  modelId: dd.modelId,
                                  adminMode: false,
                                )),
                      );
                    },
                    child: Text(
                      dd.hardwareDeviceId,
                      style: const TextStyle(
                          color: Colors.blue,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            if (dd.hardwareDeviceId != dd.deviceName)
              Tooltip(
                message: 'Device Name',
                child: Text(
                  dd.deviceName ?? '-',
                  style: const TextStyle(
                      overflow: TextOverflow.ellipsis, fontSize: 14),
                ),
              ),
            Tooltip(
              message: 'Device Model',
              child: Text(
                dd.modelName ?? '-',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis, fontSize: 14),
              ),
            ),
            Tooltip(
              message: 'Description',
              child: Text(
                dd.modelDescription ?? '-',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis, fontSize: 14),
              ),
            ),
          ],
        )),
        DataCell(Wrap(
          spacing: 4.0,
          children: [
            Text(
              timeago.format(dT, locale: 'en'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              dT.toString(),
            ),
          ],
        )),
        DataCell(Wrap(
          spacing: 4.0,
          children: [
            Tooltip(
              message: 'Premise',
              child: Text(
                dd.premise ?? '',
                style: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold),
              ),
            ),
            divider(),
            Tooltip(
              message: 'Facility',
              child: Text(
                dd.facility ?? '',
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ),
            divider(),
            Tooltip(
              message: 'Floor',
              child: Text(
                dd.floor ?? '',
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        )),
        DataCell(Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children,
            ),
          ),
        )),
      ]));
    }

    return DataTable2(
        dataRowHeight: 100,
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: columns,
        rows: rows);
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No data found'),
              divider(horizontal: true),
              const BusyIndicator(),
            ],
          )
        ],
      );
    }

    return _buildTable();
  }
}
