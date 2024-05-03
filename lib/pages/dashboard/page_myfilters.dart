import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned/pages/dashboard/page_myassets.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class MyFiltersPage extends StatefulWidget {
  const MyFiltersPage({super.key});

  @override
  State<MyFiltersPage> createState() => _MyFiltersPageState();
}

class _MyFiltersPageState extends BaseState<MyFiltersPage> {
  final List<FieldFilter> _fieldFilters = [];
  final List<DataFilter> _dataFilters = [];

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

    _dataFilters.clear();

    await execute(() async {
      var ffRes = await UserSession.twin.listFieldFilters(
          apikey: UserSession().getAuthToken(),
          body: const ListReq(page: 0, size: 10000));
      if (validateResponse(ffRes)) {
        setState(() {
          _fieldFilters.addAll(ffRes.body!.values!);
        });
      }

      var dfRes = await UserSession.twin.listDataFilters(
          apikey: UserSession().getAuthToken(),
          body: const ListReq(page: 0, size: 10000));
      if (validateResponse(dfRes)) {
        setState(() {
          _dataFilters.addAll(dfRes.body!.values!);
        });
      }
    });

    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [];

    for (var filter in _fieldFilters) {
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
                    builder: (context) => MyAssetsPage(
                          fieldFilter: filter,
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

    for (var filter in _dataFilters) {
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
                    builder: (context) => MyAssetsPage(
                          dataFilter: filter,
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
        if (_dataFilters.isNotEmpty)
          SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              children: cards,
            ),
          ),
        if (_dataFilters.isEmpty)
          const Align(
              alignment: Alignment.center, child: Text('No filter found')),
      ],
    );
  }
}
