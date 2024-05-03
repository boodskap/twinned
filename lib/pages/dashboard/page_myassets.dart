import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned/pages/dashboard/page_device_analytics.dart';
import 'package:twinned/pages/dashboard/page_device_history.dart';
import 'package:twinned/pages/widgets/topbar.dart';
import 'package:twinned/widgets/commons/datagrid_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:nocode_commons/widgets/default_assetview.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:accordion/accordion.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:accordion/controllers.dart';
import 'package:uuid/uuid.dart';

typedef BasicInfoCallback = void Function(
    String name, String? description, String? tags);

enum AssetViewType { card, grid }

class MyAssetsPage extends StatefulWidget {
  final AssetGroup? group;
  final DataFilter? dataFilter;
  final FieldFilter? fieldFilter;
  const MyAssetsPage(
      {super.key, this.group, this.dataFilter, this.fieldFilter});

  @override
  State<MyAssetsPage> createState() => _MyAssetsPageState();
}

class _MyAssetsPageState extends BaseState<MyAssetsPage> {
  final List<DeviceData> _data = [];
  AssetViewType viewType = AssetViewType.card;

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
    _load();
  }

  Future _load() async {
    if (null != widget.group) {
      await _loadData();
    } else if (null != widget.fieldFilter) {
      await _filterFieldData();
    } else if (null != widget.dataFilter) {
      await _filterData();
    }
  }

  Future _loadData() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      _data.clear();
      for (var assetId in widget.group!.assetIds) {
        var ddRes = await UserSession.twin.searchRecentDeviceData(
            apikey: UserSession().getAuthToken(),
            assetId: assetId,
            body: const FilterSearchReq(search: '*', page: 0, size: 1000));
        if (validateResponse(ddRes, shouldAlert: false)) {
          setState(() {
            viewType = AssetViewType.grid;
            _data.addAll(ddRes.body!.values!);
          });
        }
      }
    });
    loading = false;
    setState(() {
      viewType = AssetViewType.grid;
    });
  }

  Future _filterFieldData() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      _data.clear();
      var ddRes = await UserSession.twin.fieldFilterRecentDeviceData(
          apikey: UserSession().getAuthToken(),
          fieldFilterId: widget.fieldFilter!.id,
          page: 0,
          size: 10000);
      if (validateResponse(ddRes, shouldAlert: false)) {
        setState(() {
          viewType = AssetViewType.grid;
          _data.addAll(ddRes.body!.values!);
        });
      }
    });
    loading = false;
    setState(() {
      viewType = AssetViewType.grid;
    });
  }

  Future _filterData() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      _data.clear();
      var ddRes = await UserSession.twin.filterRecentDeviceData(
          apikey: UserSession().getAuthToken(),
          filterId: widget.dataFilter!.id,
          page: 0,
          size: 10000);
      if (validateResponse(ddRes, shouldAlert: false)) {
        setState(() {
          viewType = AssetViewType.grid;
          _data.addAll(ddRes.body!.values!);
        });
      }
    });
    loading = false;
    setState(() {
      viewType = AssetViewType.grid;
    });
  }

  Widget _buildCards(BuildContext context) {
    final List<Widget> cards = [];
    final List<String> assetIds = [];

    if (null != widget.group) {
      assetIds.addAll(widget.group!.assetIds);
    } else {
      for (var dd in _data) {
        if (null == dd.assetId || dd.assetId!.isEmpty) continue;
        if (!assetIds.contains(dd.assetId!)) {
          assetIds.add(dd.assetId!);
        }
      }
    }

    for (var assetId in assetIds) {
      cards.add(SizedBox(
        width: 500,
        height: 400,
        child: DefaultAssetView(
            twinned: UserSession.twin,
            authToken: UserSession().getAuthToken(),
            assetId: assetId,
            onAssetDoubleTapped: (DeviceData dd) async {
              await Navigator.push(
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
            onAssetAnalyticsTapped: (DeviceData dd) async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeviceAnalyticsPage(
                            data: dd,
                          )));
            }),
      ));
    }

    if (cards.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No data found'),
          ],
        ),
      );
    }

    return Flexible(
      child: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return cards[index];
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    late final String name;
    late final FilterType filterType;
    String? filterId;

    if (null != widget.group) {
      name = widget.group!.name;
      filterType = FilterType.group;
    } else if (null != widget.fieldFilter) {
      name = widget.fieldFilter!.name;
      filterType = FilterType.field;
      filterId = widget.fieldFilter!.id;
    } else if (null != widget.dataFilter) {
      name = widget.dataFilter!.name;
      filterType = FilterType.data;
      filterId = widget.dataFilter!.id;
    }

    return Scaffold(
      body: Column(
        children: [
          TopBar(title: '$name - Assets'),
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
                    switch (viewType) {
                      case AssetViewType.card:
                        setState(() {});
                      case AssetViewType.grid:
                        await _load();
                        break;
                    }
                  },
                  icon: const Icon(Icons.refresh)),
              divider(horizontal: true),
              IconButton(
                  tooltip: 'Card View',
                  onPressed: viewType == AssetViewType.card
                      ? null
                      : () async {
                          setState(() {
                            viewType = AssetViewType.card;
                          });
                        },
                  icon: Icon(Icons.view_comfy,
                      color:
                          viewType == AssetViewType.card ? Colors.blue : null)),
              divider(horizontal: true),
              IconButton(
                  tooltip: 'Data Grid View',
                  onPressed: viewType == AssetViewType.grid
                      ? null
                      : () async {
                          await _load();
                        },
                  icon: Icon(Icons.view_compact_outlined,
                      color:
                          viewType == AssetViewType.grid ? Colors.blue : null)),
              divider(horizontal: true),
            ],
          ),
          divider(),
          if (viewType == AssetViewType.card) _buildCards(context),
          if (viewType == AssetViewType.grid)
            Flexible(
              child: DataGridSnippet(
                key: Key(const Uuid().v4()),
                filterType: filterType,
                group: widget.group,
                filterId: filterId,
              ),
            ),
        ],
      ),
    );
  }
}
