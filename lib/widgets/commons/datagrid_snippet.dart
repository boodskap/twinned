import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:nocode_commons/widgets/default_assetview.dart';
import 'package:nocode_commons/widgets/device_component.dart';
import 'package:twinned/pages/dashboard/page_device_history.dart';
import 'package:twinned/pages/dashboard/page_field_analytics.dart';
import 'package:twinned/pages/dashboard/page_modelgrid.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:data_table_2/data_table_2.dart';
import 'package:nocode_commons/twinned_widgets.dart' as widgets;
import 'package:chopper/chopper.dart' as chopper;
import 'package:uuid/uuid.dart';

enum FilterType { none, data, field, group, model }

class DataGridSnippet extends StatefulWidget {
  final FilterType filterType;
  final AssetGroup? group;
  final String? filterId;
  final String? modelId;
  const DataGridSnippet(
      {super.key,
      required this.filterType,
      this.group,
      this.filterId,
      this.modelId});

  @override
  State<DataGridSnippet> createState() => DataGridSnippetState();
}

class DataGridSnippetState extends BaseState<DataGridSnippet> {
  final List<DeviceData> _data = [];
  final Map<String, DeviceModel> _models = {};
  final List<String> _modelIds = [];
  Timer? timer;

  @override
  void setup() {
    load();
    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) => load());
  }

  @override
  void dispose() {
    super.dispose();
    if (null != timer) {
      timer!.cancel();
    }
  }

  void showAnalytics(
      {required bool asPopup,
      required List<String> fields,
      required DeviceModel deviceModel,
      required DeviceData dd}) {
    if (asPopup) {
      alertDialog(
          title: '',
          width: MediaQuery.of(context).size.width - 100,
          body: FieldAnalyticsPage(
            fields: fields,
            deviceModel: deviceModel,
            deviceData: dd,
            asPopup: asPopup,
            canDeleteRecord: UserSession().isAdmin(),
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FieldAnalyticsPage(
                    fields: fields,
                    deviceModel: deviceModel,
                    deviceData: dd,
                    canDeleteRecord: UserSession().isAdmin(),
                  )));
    }
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
      _modelIds.clear();

      late final chopper.Response<DeviceDataArrayRes> dRes;

      switch (widget.filterType) {
        case FilterType.none:
        case FilterType.model:
          dRes = await UserSession.twin.searchRecentDeviceData(
              apikey: UserSession().getAuthToken(),
              modelId: widget.modelId,
              body: FilterSearchReq(search: search, page: page, size: size));
          break;
        case FilterType.data:
          dRes = await UserSession.twin.filterRecentDeviceData(
              apikey: UserSession().getAuthToken(),
              filterId: widget.filterId,
              page: page,
              size: size);
          break;
        case FilterType.field:
          dRes = await UserSession.twin.fieldFilterRecentDeviceData(
              apikey: UserSession().getAuthToken(),
              fieldFilterId: widget.filterId,
              page: page,
              size: size);
          break;
        case FilterType.group:
          break;
        // TODO: Handle this case.
      }

      if (widget.filterType != FilterType.group) {
        if (validateResponse(dRes)) {
          _data.addAll(dRes.body!.values!);

          for (DeviceData dd in _data) {
            if (_modelIds.contains(dd.modelId)) continue;
            _modelIds.add(dd.modelId);
          }

          var mRes = await UserSession.twin.getDeviceModels(
              apikey: UserSession().getAuthToken(),
              body: GetReq(ids: _modelIds));

          if (validateResponse(mRes)) {
            for (var deviceModel in mRes.body!.values!) {
              _models[deviceModel.id] = deviceModel;
            }
          }
        }
      } else {
        for (String assetId in widget.group!.assetIds) {
          var sRes = await UserSession.twin.searchRecentDeviceData(
              apikey: UserSession().getAuthToken(),
              assetId: assetId,
              body: FilterSearchReq(search: search, page: page, size: size));

          if (validateResponse(sRes)) {
            _data.addAll(sRes.body!.values!);

            for (DeviceData dd in _data) {
              if (_modelIds.contains(dd.modelId)) continue;
              _modelIds.add(dd.modelId);
            }
          }
        }

        var mRes = await UserSession.twin.getDeviceModels(
            apikey: UserSession().getAuthToken(), body: GetReq(ids: _modelIds));

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
        fixedWidth: 200,
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
        fixedWidth: 200,
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
        fixedWidth: 200,
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
        fixedWidth: 200,
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
      const DataColumn2(
        fixedWidth: 300,
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.add_alert),
            Text(
              'Alarms',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      const DataColumn2(
        //fixedWidth: 400,
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.menu),
            Text(
              'Sensor Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    ]);

    if (_models.isNotEmpty) {
      for (var dd in _data) {
        var dT = DateTime.fromMillisecondsSinceEpoch(dd.updatedStamp);
        List<Widget> children = [];
        Map<String, dynamic> dynData = dd.data as Map<String, dynamic>;
        DeviceModel deviceModel = _models[dd.modelId]!;
        List<String> fields = NoCodeUtils.getSortedFields(deviceModel);
        List<String> timeSeriesFields =
            NoCodeUtils.getTimeSeriesFields(deviceModel);

        for (String field in fields) {
          widgets.SensorWidgetType type =
              NoCodeUtils.getSensorWidgetType(field, _models[dd.modelId]!);
          bool hasSeries = timeSeriesFields.contains(field);
          if (type == widgets.SensorWidgetType.none) {
            String iconId = NoCodeUtils.getParameterIcon(field, deviceModel);
            _padding(children);
            children.add(InkWell(
              onTap: !hasSeries
                  ? null
                  : () {
                      showAnalytics(
                          asPopup: true,
                          fields: [field],
                          deviceModel: deviceModel,
                          dd: dd);
                    },
              onDoubleTap: !hasSeries
                  ? null
                  : () {
                      showAnalytics(
                          asPopup: false,
                          fields: [field],
                          deviceModel: deviceModel,
                          dd: dd);
                    },
              child: Column(
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
              ),
            ));
            children.add(divider(horizontal: true, width: 24));
          } else {
            Parameter? parameter =
                NoCodeUtils.getParameter(field, _models[dd.modelId]!);
            children.add(InkWell(
              onTap: !hasSeries
                  ? null
                  : () {
                      showAnalytics(
                          asPopup: true,
                          fields: [field],
                          deviceModel: deviceModel,
                          dd: dd);
                    },
              onDoubleTap: !hasSeries
                  ? null
                  : () {
                      showAnalytics(
                          asPopup: false,
                          fields: [field],
                          deviceModel: deviceModel,
                          dd: dd);
                    },
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: 80,
                      minHeight: 160,
                      maxWidth: 80,
                      maxHeight: 160),
                  child: widgets.SensorWidget(
                    parameter: parameter!,
                    deviceData: dd,
                    deviceModel: deviceModel,
                    tiny: true,
                  )),
            ));
          }
        }

        rows.add(DataRow2(cells: [
          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: null == dd.assetId
                    ? null
                    : () async {
                        alertDialog(
                            title: dd.asset ?? '-',
                            body: DefaultAssetView(
                                twinned: UserSession.twin,
                                authToken: UserSession().getAuthToken(),
                                assetId: dd.assetId!,
                                onAssetDoubleTapped: (dd) async {},
                                onAssetAnalyticsTapped:
                                    (field, deviceModel, dd) async {
                                  showAnalytics(
                                      asPopup: true,
                                      fields: [field],
                                      deviceModel: deviceModel,
                                      dd: dd);
                                }));
                      },
                child: Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      dd.asset ?? '-',
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold),
                    ),
                    if (timeSeriesFields.isNotEmpty)
                      InkWell(
                          onTap: () {
                            showAnalytics(
                                asPopup: true,
                                fields: timeSeriesFields,
                                deviceModel: deviceModel,
                                dd: dd);
                          },
                          onDoubleTap: () {
                            showAnalytics(
                                asPopup: false,
                                fields: timeSeriesFields,
                                deviceModel: deviceModel,
                                dd: dd);
                          },
                          child: const Icon(Icons.bar_chart))
                  ],
                ),
              ),
            ],
          )),
          DataCell(Wrap(
            spacing: 4.0,
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
                        fontSize: 16),
                  ),
                ),
              ),
              if (dd.hardwareDeviceId != dd.deviceName)
                Tooltip(
                  message: 'Device Name',
                  child: Text(
                    dd.deviceName ?? '-',
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis, fontSize: 16),
                  ),
                ),
              Tooltip(
                message: 'Device Model',
                child: InkWell(
                  onTap: widget.filterType == FilterType.model
                      ? null
                      : () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DeviceModelGridPage(
                                      title: '${dd.modelName} - Assets',
                                      child: DataGridSnippet(
                                        filterType: FilterType.model,
                                        modelId: dd.modelId,
                                      ))));
                        },
                  child: Text(
                    dd.modelName ?? '-',
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis, fontSize: 16),
                  ),
                ),
              ),
            ],
          )),
          DataCell(Wrap(
            spacing: 4.0,
            children: [
              Text(
                timeago.format(dT, locale: 'en'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16),
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
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Tooltip(
                message: 'Facility',
                child: Text(
                  dd.facility ?? '',
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
              Tooltip(
                message: 'Floor',
                child: Text(
                  dd.floor ?? '',
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          )),
          if (dd.alarms.isNotEmpty ||
              dd.displays.isNotEmpty ||
              dd.controls!.isNotEmpty)
            DataCell(
              DeviceComponentView(
                  twinned: UserSession.twin,
                  authToken: UserSession().getAuthToken(),
                  deviceData: dd),
            ),
          if (dd.alarms.isEmpty && dd.displays.isEmpty && dd.controls!.isEmpty)
            const DataCell(
              Text(''),
            ),
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
    }

    return DataTable2(
        key: Key(const Uuid().v4()),
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
