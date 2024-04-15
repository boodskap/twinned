import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

import '../widgets/topbar.dart';

enum ReportType { status, history }

class MyReportPage extends StatefulWidget {
  final Report report;
  final ReportType reportType;
  final String? deviceId;

  const MyReportPage(
      {super.key,
      required this.report,
      required this.reportType,
      this.deviceId});

  @override
  State<MyReportPage> createState() => _MyReportPageState();
}

class _MyReportPageState extends BaseState<MyReportPage> {
  Widget bannerImage = Image.asset(
    'assets/images/ldashboard_banner.png',
    fit: BoxFit.cover,
  );
  final List<DeviceData> _data = [];
  RangeFilter? filter;
  DeviceModel? model;

  @override
  void initState() {
    if (null != twinSysInfo && twinSysInfo!.bannerImage!.isNotEmpty) {
      bannerImage = UserSession()
          .getImage(domainKey, twinSysInfo!.bannerImage!, fit: BoxFit.cover);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(title: 'Report'),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: bannerImage,
          ),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const BusyIndicator(),
              divider(horizontal: true),
              IconButton(
                  tooltip: 'reload data',
                  onPressed: () async {
                    await _load();
                  },
                  icon: const Icon(Icons.refresh)),
              divider(horizontal: true),
            ],
          ),
          divider(),
          if (null == model)
            const SizedBox(
              height: 100,
              child: Text('No data found'),
            ),
          if (null != model)
            Flexible(
              child: SingleChildScrollView(
                child: widget.reportType == ReportType.status
                    ? _buildStatus(context)
                    : _buildHistory(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    final List<DataColumn> columns = [];
    final List<DataRow> rows = [];
    final List<String> fields = NoCodeUtils.getSortedFields(model!);

    fields.removeWhere((field) => !widget.report.fields.contains(field));

    if (widget.report.includeAsset ?? true) {
      columns.add(const DataColumn(
          label: Expanded(
        child: Text(
          'Asset',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )));
    }

    if (widget.report.includeDevice ?? true) {
      columns.add(const DataColumn(
          label: Expanded(
        child: Text(
          'Device',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )));
    }

    columns.add(const DataColumn(
        label: Expanded(
      child: Text(
        'Last Reported',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    )));

    for (String field in fields) {
      String label = NoCodeUtils.getParameterLabel(field, model!);
      String unit = NoCodeUtils.getParameterUnit(field, model!);
      String? icon = NoCodeUtils.getParameterIcon(field, model!);
      Widget? image;

      if (icon.isNotEmpty) {
        image = UserSession().getImage(widget.report.domainKey, icon);
      }

      columns.add(DataColumn(
          label: Expanded(
        child: Row(
          children: [
            if (null != image) SizedBox(width: 16, height: 16, child: image),
            if (null != image) divider(horizontal: true, width: 4),
            Text(
              '$label ($unit)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      )));
    }

    if (widget.report.includePremise ?? true) {
      columns.add(const DataColumn(
          label: Expanded(
        child: Text(
          'Premise',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )));
    }

    if (widget.report.includeFacility ?? true) {
      columns.add(const DataColumn(
          label: Expanded(
        child: Text(
          'Facility',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )));
    }

    if (widget.report.includeFloor ?? true) {
      columns.add(const DataColumn(
          label: Expanded(
        child: Text(
          'Floor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )));
    }

    for (DeviceData dd in _data) {
      Map<String, dynamic> map = dd.data as Map<String, dynamic>;
      List<DataCell> cells = [];

      if (widget.report.includeAsset ?? true) {
        cells.add(DataCell(Text(dd.asset ?? '-')));
      }

      if (widget.report.includeDevice ?? true) {
        cells.add(DataCell(Text(dd.deviceName ?? '-')));
      }

      cells.add(DataCell(Text(
          DateTime.fromMillisecondsSinceEpoch(dd.updatedStamp).toString())));

      for (String field in fields) {
        cells.add(DataCell(Text('${map[field] ?? '-'}')));
      }

      if (widget.report.includePremise ?? true) {
        cells.add(DataCell(Text(dd.premise ?? '-')));
      }

      if (widget.report.includeFacility ?? true) {
        cells.add(DataCell(Text(dd.facility ?? '-')));
      }

      if (widget.report.includeFloor ?? true) {
        cells.add(DataCell(Text(dd.floor ?? '-')));
      }

      rows.add(DataRow(cells: cells));
    }

    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(columns: columns, rows: rows));
  }

  Widget _buildHistory(BuildContext context) {
    return const Placeholder();
  }

  @override
  void setup() async {
    await _load();
  }

  Future _load() async {
    await execute(() async {
      var res = await UserSession.twin.getDeviceModel(
          apikey: UserSession().getAuthToken(), modelId: widget.report.modelId);
      if (validateResponse(res)) {
        setState(() {
          model = res.body!.entity;
        });
      }
    });

    widget.reportType == ReportType.status
        ? await _loadStatus()
        : await _loadHistory();
  }

  Future _loadStatus() async {
    if (loading) return;
    loading = true;
    _data.clear();
    await execute(() async {
      var res = await UserSession.twin.searchRecentDeviceData(
          apikey: UserSession().getAuthToken(),
          modelId: widget.report.modelId,
          body: FilterSearchReq(
              search: '*', filter: filter, page: 0, size: 10000));
      if (validateResponse(res)) {
        setState(() {
          _data.addAll(res.body?.values ?? []);
        });
      }
    });
    loading = false;
  }

  Future _loadHistory() async {
    if (loading) return;
    loading = true;
    _data.clear();
    await execute(() async {
      var res = await UserSession.twin.searchDeviceHistoryData(
          apikey: UserSession().getAuthToken(),
          deviceId: widget.deviceId!,
          body: FilterSearchReq(
              search: '*', filter: filter, page: 0, size: 1000));
      if (validateResponse(res)) {
        setState(() {
          _data.addAll(res.body?.values ?? []);
        });
      }
    });
    loading = false;
  }
}
