import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twin_commons/analytics/field_analytics.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/core/ui.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/widgets/layout.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

class FieldAnalyticsPage extends StatefulWidget {
  final List<String> fields;
  final twin.DeviceData deviceData;
  final twin.DeviceModel deviceModel;
  final bool asPopup;
  final bool canDeleteRecord;
  const FieldAnalyticsPage({
    super.key,
    required this.fields,
    required this.deviceData,
    required this.deviceModel,
    required this.canDeleteRecord,
    this.asPopup = false,
  });

  @override
  State<FieldAnalyticsPage> createState() => _FieldAnalyticsPageState();
}

class _FieldAnalyticsPageState extends BaseState<FieldAnalyticsPage> {
  Widget _bannerImage = Image.asset(
    'assets/images/ldashboard_banner.png',
    fit: BoxFit.cover,
  );

  @override
  void initState() {
    if (null != twinSysInfo && twinSysInfo!.bannerImage!.isNotEmpty) {
      _bannerImage = UserSession()
          .getImage(domainKey, twinSysInfo!.bannerImage!, fit: BoxFit.contain);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String title;
    if (widget.fields.length > 1) {
      title = '${widget.deviceData.asset} - Time Series';
    } else {
      title =
          '${widget.deviceData.asset} - ${TwinUtils.getParameterLabel(widget.fields[0], widget.deviceModel)} (${TwinUtils.getParameterUnit(widget.fields[0], widget.deviceModel)}) - Time Series';
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F65AD),
        centerTitle: true,
        leading: const BackButton(
          color: Color(0XFFFFFFFF),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0XFFFFFFFF),
          ),
        ),
        actions: <Widget>[
          if (!widget.asPopup)
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
          if (!widget.asPopup)
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 100.0,
                child: _bannerImage),
          Expanded(
            child: DeviceFieldAnalytics(
              twinned: UserSession.twin,
              apiKey: UserSession().getAuthToken(),
              canDeleteRecord: widget.canDeleteRecord,
              deviceModel: widget.deviceModel,
              deviceData: widget.deviceData,
              fields: widget.fields,
            ),
          ),
        ],
      ),
    );
  }

  Future load() async {}

  @override
  void setup() {
    load();
  }
}
