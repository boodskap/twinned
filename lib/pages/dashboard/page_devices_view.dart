import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/widgets/default_deviceview.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/pages/dashboard/page_device_analytics.dart';
import 'package:twinned/pages/dashboard/page_device_history.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned/pages/dashboard/page_field_analytics.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

class DevicesViewPage extends StatefulWidget {
  const DevicesViewPage({super.key});

  @override
  State<DevicesViewPage> createState() => _DevicesViewPageState();
}

class _DevicesViewPageState extends BaseState<DevicesViewPage> {
  late Image bannerImage;
  String search = "*";
  final List<Widget> _cards = [];
  @override
  bool loading = false;

  @override
  void initState() {
    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );
    super.initState();
  }

  @override
  void setup() async {
    await _loadEntities();
  }

  Future _loadEntities() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      _cards.clear();

      if (search.trim().isEmpty) {
        search = '*';
      }
      List<twin.DeviceData> data = [];
      List<Widget> cards = [];
      var res = await UserSession.twin.searchRecentDeviceData(
          apikey: UserSession().getAuthToken(),
          body: twin.FilterSearchReq(
            search: search,
            page: 0,
            size: 100,
          ));
      if (validateResponse(res)) {
        data.addAll(res.body!.values!);
      }

      for (var dd in data) {
        _buildCard(dd, cards);
      }

      refresh(sync: () {
        _cards.clear();
        _cards.addAll(cards);
      });
    });
    loading = false;
  }

  void _buildCard(twin.DeviceData data, List<Widget> cards) {
    cards.add(SizedBox(
      width: 450,
      height: 450,
      child: Card(
        elevation: 10,
        child: DefaultDeviceView(
          deviceData: data,
          deviceId: data.deviceId,
          twinned: UserSession.twin,
          authToken: UserSession().getAuthToken(),
          onDeviceAnalyticsTapped: (field, deviceModel, dd) async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FieldAnalyticsPage(
                          field: field,
                          deviceModel: deviceModel,
                          deviceData: dd,
                        )));
          },
          onDeviceDoubleTapped: (dd) {
            return Navigator.push(
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    int count = 4;

    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: bannerImage,
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            divider(horizontal: true),
            IconButton(
                onPressed: () async {
                  await _loadEntities();
                },
                icon: const Icon(Icons.refresh)),
            divider(horizontal: true),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 300,
                height: 30,
                child: SearchBar(
                    hintText: 'Search',
                    leading: const FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 16,
                    ),
                    onChanged: (String value) {
                      search = value.isEmpty ? '*' : value;
                      _loadEntities();
                    }),
              ),
            ),
          ],
        ),
        divider(),
        Flexible(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              children: _cards,
            ),
          ),
        ),
      ],
    );
  }
}
