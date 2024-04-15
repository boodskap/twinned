import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:nocode_commons/widgets/common/layout.dart';
import 'package:nocode_commons/widgets/common/trends_layout.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends BaseState<AnalyticsPage> {
  @override
  bool loading = true;
  final List<Widget> _children = [];

  @override
  void initState() {
    debugPrint('Building analytics...');
    super.initState();
  }

  @override
  void setup() async {
    loading = true;
    try {
      _children.clear();

      var res = await UserSession.twin.listDeviceModels(
        apikey: UserSession().getAuthToken(),
        body: const twin.ListReq(page: 0, size: 1000),
      );

      List<Map<twin.DeviceModel, twin.Parameter>> timeSeriesFields = [];
      List<Map<twin.DeviceModel, twin.Parameter>> trendFields = [];

      if (validateResponse(res)) {
        for (var model in res.body!.values!) {
          for (var param in model.parameters) {
            debugPrint('Checking param: ${param.name}');
            if (param.enableTimeSeries ?? false) {
              Map<twin.DeviceModel, twin.Parameter> map = {};
              map[model] = param;
              timeSeriesFields.add(map);
            }

            if (param.enableTrend ?? false) {
              Map<twin.DeviceModel, twin.Parameter> map = {};
              map[model] = param;
              trendFields.add(map);
            }
          }
        }
      }

      for (var mf in timeSeriesFields) {
        mf.forEach((m, f) async {
          await _buildDeviceSeries(m, f, _children);
        });
      }

      for (var mf in trendFields) {
        mf.forEach((m, f) async {
          await _buildDeviceTrends(m, f, _children);
        });
      }
    } finally {
      loading = false;
    }
  }

  Future _buildDeviceSeries(twin.DeviceModel model, twin.Parameter field,
      List<Widget> children) async {
    debugPrint('Building time series param: $field');

    var res = await UserSession.twin.listDevices(
        apikey: UserSession().getAuthToken(),
        modelId: model.id,
        body: const twin.ListReq(page: 0, size: 2));

    if (validateResponse(res)) {
      for (var dev in res.body!.values!) {
        _buildTimeSeries(model, dev, field, children);
      }
    }
  }

  void _buildTimeSeries(twin.DeviceModel model, twin.Device dev,
      twin.Parameter field, List<Widget> children) {
    debugPrint('Building time series device:${dev.name} param: ${field.name}');

    var widget = TimeSeriesLayoutWidget(
      twinned: UserSession.twin,
      apiKey: UserSession().getAuthToken(),
      height: 160,
      model: model,
      deviceId: dev.id,
      field: field.name,
      title: '${dev.name} -> ${field.label} - Time Series',
    );
    children.add(widget);
    refresh(sync: () {});
  }

  Future _buildDeviceTrends(twin.DeviceModel model, twin.Parameter field,
      List<Widget> children) async {
    debugPrint('Building trends param: $field');

    var res = await UserSession.twin.listDevices(
        apikey: UserSession().getAuthToken(),
        modelId: model.id,
        body: const twin.ListReq(page: 0, size: 2));

    if (validateResponse(res)) {
      for (var dev in res.body!.values!) {
        _buildTrends(model, dev, field, children);
      }
    }
  }

  void _buildTrends(twin.DeviceModel model, twin.Device dev,
      twin.Parameter field, List<Widget> children) {
    debugPrint('Building trends device:${dev.name} param: ${field.name}');

    var widget = TrendsLayoutWidget(
      twinned: UserSession.twin,
      apiKey: UserSession().getAuthToken(),
      height: 160,
      model: model,
      deviceId: dev.id,
      field: field.name,
      title: '${dev.name} -> ${field.label} - Trends',
    );
    children.add(widget);
    refresh(sync: () {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(alignment: Alignment.centerRight, child: BusyIndicator()),
          if (_children.isNotEmpty)
            ..._children.map((e) {
              return e;
            }),
          if (_children.isEmpty && !loading)
            const Center(child: Text('Analytics not configured')),
          if (_children.isEmpty && loading)
            const Center(child: Text('Loading...')),
        ],
      ),
    );
  }
}
