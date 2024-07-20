import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned/pages/dashboard/page_reports.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends BaseState<MyReportsPage> {
  final List<Report> _reports = [];

  Widget bannerImage = Image.asset(
    'assets/images/ldashboard_banner.png',
    fit: BoxFit.cover,
  );

  @override
  void initState() {
    if (null != twinSysInfo && twinSysInfo!.bannerImage!.isNotEmpty) {
      bannerImage = UserSession()
          .getImage(domainKey, twinSysInfo!.bannerImage!, fit: BoxFit.cover);
    }
    super.initState();
  }

  @override
  void setup() async {
    await _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      _reports.clear();
      var res = await UserSession.twin.listReports(
          apikey: UserSession().getAuthToken(),
          body: const ListReq(page: 0, size: 10000));
      if (validateResponse(res)) {
        setState(() {
          _reports.addAll(res.body!.values!);
        });
      }
      if (_reports.isNotEmpty) {
        debugPrint(_reports.first.toString());
      }
    });
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [];

    for (var filter in _reports) {
      Widget? image;
      if (null != filter.icon && filter.icon!.isNotEmpty) {
        image = UserSession().getImage(filter.domainKey, filter.icon!);
      }
      cards.add(SizedBox(
          width: 200,
          height: 200,
          child: InkWell(
            onDoubleTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyReportPage(
                          report: filter,
                          reportType: ReportType.status,
                        )),
              );
            },
            child: Card(
              elevation: 10,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (null != image)
                        SizedBox(width: 48, height: 48, child: image),
                      if (null != image) divider(),
                      Tooltip(
                          message: filter.name,
                          child: Text(
                            filter.name,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          )));
    }

    return Column(
      children: [
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
        if (_reports.isNotEmpty)
          SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              children: cards,
            ),
          ),
        if (_reports.isEmpty)
          const Align(
              alignment: Alignment.center, child: Text('No report found')),
      ],
    );
  }
}
