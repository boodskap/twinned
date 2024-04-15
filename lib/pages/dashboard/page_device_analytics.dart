import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/ui.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/widgets/common/layout.dart';
import 'package:nocode_commons/widgets/common/trends_layout.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

class DeviceAnalyticsPage extends StatefulWidget {
  final twin.DeviceData data;
  const DeviceAnalyticsPage({super.key, required this.data});

  @override
  State<DeviceAnalyticsPage> createState() => _DeviceAnalyticsPageState();
}

class _DeviceAnalyticsPageState extends BaseState<DeviceAnalyticsPage> {
  Widget _bannerImage = Image.asset(
    'assets/images/ldashboard_banner.png',
    fit: BoxFit.cover,
  );

  twin.DeviceModel? _model;
  twin.Device? _device;
  final List<twin.Parameter> _seriesFields = [];
  final List<twin.Parameter> _trendFields = [];
  final List<Widget> _children = [];

  @override
  void initState() {
    if (null != twinSysInfo && twinSysInfo!.bannerImage!.isNotEmpty) {
      _bannerImage = UserSession()
          .getImage(domainKey, twinSysInfo!.bannerImage!, fit: BoxFit.cover);
    }
    super.initState();
  }

  @override
  void setup() async {
    await _load();
  }

  Future _load() async {
    await execute(() async {
      _seriesFields.clear();
      _trendFields.clear();
      _children.clear();

      var dRes = await UserSession.twin.getDevice(
          apikey: UserSession().getAuthToken(), deviceId: widget.data.deviceId);
      if (validateResponse(dRes)) {
        _device = dRes.body!.entity!;
      }

      if (null == _device) return;

      var res = await UserSession.twin.getDeviceModel(
          apikey: UserSession().getAuthToken(), modelId: widget.data.modelId);

      if (validateResponse(res)) {
        _model = res.body!.entity;

        for (var param in _model!.parameters) {
          if (param.enableTimeSeries ?? false) {
            _seriesFields.add(param);
          }
          if (param.enableTrend ?? false) {
            _trendFields.add(param);
          }
        }
      }

      for (var param in _seriesFields) {
        _buildTimeSeries(_model!, _device!, param, _children);
      }

      for (var param in _trendFields) {
        _buildTrends(_model!, _device!, param, _children);
      }

      refresh();
    });
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
      title: '${field.label} - Time Series',
    );
    children.add(widget);
    children.add(divider());
    refresh(sync: () {});
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
      title: '${field.label} - Trends',
    );
    children.add(widget);
    children.add(divider());
    refresh(sync: () {});
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
          '${widget.data.deviceName} - Analytics',
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
            child: _bannerImage,
          ),
          divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BusyIndicator(),
            ],
          ),
          divider(),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: _children,
              ),
            ),
          ),
          // ..._children
        ],
      ),
    );
  }
}
