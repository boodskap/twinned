import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:nocode_commons/widgets/default_assetview.dart';
import 'package:twinned/pages/dashboard/page_device_analytics.dart';
import 'package:twinned/pages/dashboard/page_field_analytics.dart';
import 'package:twinned/pages/widgets/asset_infra_card.dart';
import 'package:twinned/pages/widgets/device_infra_card.dart';
import 'package:twinned/pages/widgets/facility_infra_card.dart';
import 'package:twinned/pages/widgets/floor_infra_card.dart';
import 'package:twinned/pages/widgets/premise_infra_card.dart';
import 'package:twinned/providers/state_provider.dart';
import 'package:twinned/widgets/commons/datagrid_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:twinned_widgets/twinned_dashboard_widget.dart';

enum CurrentView { home, map, asset, grid }

class InfraPage extends StatefulWidget {
  final TwinInfraType type;
  CurrentView currentView;
  final Premise? premise;
  final Facility? facility;
  final Floor? floor;
  final Asset? asset;

  InfraPage(
      {super.key,
      required this.type,
      required this.currentView,
      this.premise,
      this.facility,
      this.floor,
      this.asset});

  @override
  State<InfraPage> createState() => _InfraPageState();
}

class _InfraPageState extends BaseState<InfraPage> {
  Widget bannerImage = Image.asset(
    'assets/images/ldashboard_banner.png',
    fit: BoxFit.cover,
  );

  String search = '*';
  final List<Premise> _premises = [];
  final List<Facility> _facilities = [];
  final List<Floor> _floors = [];
  final List<Asset> _assets = [];
  final List<Device> _devices = [];
  final Map<String, PremiseStats> _premiseStats = {};
  final Map<String, FacilityStats> _facilityStats = {};
  final Map<String, FloorStats> _floorStats = {};
  final List<DeviceData> _data = [];
  final List<Widget> _menus = [];

  final GlobalKey<_InfraMapViewState> mapViewKey = GlobalKey();
  final GlobalKey<_InfraAssetViewState> assetViewKey = GlobalKey();
  final GlobalKey<DataGridSnippetState> dataGridKey = GlobalKey();

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

  Future _loadData() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      _data.clear();
      var res = await UserSession.twin.searchRecentDeviceData(
          apikey: UserSession().getAuthToken(),
          assetId: widget.asset?.id,
          floorId: widget.floor?.id,
          facilityId: widget.facility?.id,
          premiseId: widget.premise?.id,
          body: FilterSearchReq(search: search, page: 0, size: 1000));
      if (validateResponse(res)) {
        List<DeviceData> data = [];
        data.addAll(res.body!.values!);
        refresh(sync: () {
          _data.addAll(data);
        });
      }
    });

    loading = false;
  }

  Future _load() async {
    await _loadMenus();
    if (widget.currentView == CurrentView.grid) {
      return _loadData();
    }
    if (loading) return;
    loading = true;

    await execute(() async {
      switch (widget.type) {
        case TwinInfraType.premise:
          await _loadPremises();
          break;
        case TwinInfraType.facility:
          await _loadFacilities();
          break;
        case TwinInfraType.floor:
          await _loadFloors();
          break;
        case TwinInfraType.asset:
          await _loadAssets();
          break;
        case TwinInfraType.device:
          await _loadDevices();
          break;
      }
    });
    loading = false;
  }

  Future _loadMenus() async {
    _menus.clear();
    var res = await UserSession.twin.listDashboardMenuGroups(
        apikey: UserSession().getAuthToken(),
        body: const ListReq(page: 0, size: 10));
    if (validateResponse(res)) {
      for (DashboardMenuGroup val in res.body!.values!) {
        List<DropdownMenuItem<DashboardMenu>> items = [];

        for (DashboardMenu cval in val.menus) {
          items.add(DropdownMenuItem<DashboardMenu>(
            value: cval,
            child: Text(
              cval.displayName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ));
        }
        debugPrint('Loaded ${items.length} menus items');

        Widget menu = DropdownButtonHideUnderline(
            child: DropdownButton2<DashboardMenu>(
          customButton: Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(
                Icons.list,
                size: 46,
                color: Colors.red,
              ),
              Text(
                val.displayName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            ],
          ),
          items: items,
          onChanged: (menu) {
            if (null == menu) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TwinnedDashboardWidget(
                          popupMode: true,
                          screenId: menu!.screenId,
                        )));
          },
        ));

        _menus.add(menu);
      }
    }
    debugPrint('Loaded ${_menus.length} menus');
    refresh();
  }

  Future _loadPremises() async {
    List<Premise> entities = [];
    _premises.clear();

    var res = await UserSession.twin.searchPremises(
        apikey: UserSession().getAuthToken(),
        body: SearchReq(search: search, page: 0, size: 25));

    if (validateResponse(res)) {
      entities.addAll(res.body!.values!);

      for (var e in entities) {
        var sRes = await UserSession.twin.getPremiseStats(
            apikey: UserSession().getAuthToken(), premiseId: e.id);
        if (validateResponse(sRes)) {
          _premiseStats[e.id] = sRes.body!.entity!;
        }
      }

      refresh(sync: () {
        _premises.addAll(entities);
      });
    }
  }

  Future _loadFacilities() async {
    List<Facility> entities = [];
    _facilities.clear();

    var res = await UserSession.twin.searchFacilities(
        apikey: UserSession().getAuthToken(),
        premiseId: widget.premise?.id,
        body: SearchReq(search: search, page: 0, size: 50));

    for (var e in entities) {
      var sRes = await UserSession.twin.getFacilityStats(
          apikey: UserSession().getAuthToken(), facilityId: e.id);
      if (validateResponse(sRes)) {
        _facilityStats[e.id] = sRes.body!.entity!;
      }
    }

    if (validateResponse(res)) {
      entities.addAll(res.body!.values!);
      refresh(sync: () {
        _facilities.addAll(entities);
      });
    }
  }

  Future _loadFloors() async {
    List<Floor> entities = [];
    _floors.clear();

    var res = await UserSession.twin.searchFloors(
        apikey: UserSession().getAuthToken(),
        premiseId: widget.premise?.id,
        facilityId: widget.facility?.id,
        body: SearchReq(search: search, page: 0, size: 150));

    for (var e in entities) {
      var sRes = await UserSession.twin
          .getFloorStats(apikey: UserSession().getAuthToken(), floorId: e.id);
      if (validateResponse(sRes)) {
        _floorStats[e.id] = sRes.body!.entity!;
      }
    }

    if (validateResponse(res)) {
      entities.addAll(res.body!.values!);
      refresh(sync: () {
        _floors.addAll(entities);
      });
    }
  }

  Future _loadAssets() async {
    List<Asset> entities = [];
    _assets.clear();

    var res = await UserSession.twin.searchAssets(
        apikey: UserSession().getAuthToken(),
        premiseId: widget.premise?.id,
        facilityId: widget.facility?.id,
        floorId: widget.floor?.id,
        body: SearchReq(search: search, page: 0, size: 50));

    if (validateResponse(res)) {
      entities.addAll(res.body!.values!);
      refresh(sync: () {
        _assets.addAll(entities);
      });
    }
  }

  Future _loadDevices() async {
    List<Device> entities = [];
    _devices.clear();

    var res = await UserSession.twin.searchDevices(
        apikey: UserSession().getAuthToken(),
        premiseId: widget.premise?.id,
        facilityId: widget.facility?.id,
        floorId: widget.floor?.id,
        assetId: widget.asset?.id,
        body: SearchReq(search: search, page: 0, size: 50));

    if (validateResponse(res)) {
      entities.addAll(res.body!.values!);
      refresh(sync: () {
        _devices.addAll(entities);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ..._menus,
            divider(horizontal: true),
            IconButton(
                tooltip: 'Infrastructure View',
                onPressed: widget.currentView == CurrentView.home
                    ? null
                    : () {
                        setState(() {
                          widget.currentView = CurrentView.home;
                        });
                      },
                icon: Icon(
                  Icons.home,
                  color: widget.currentView == CurrentView.home
                      ? Colors.green
                      : Colors.black,
                )),
            divider(horizontal: true),
            IconButton(
                tooltip: 'Map View',
                onPressed: widget.currentView == CurrentView.map
                    ? null
                    : () {
                        setState(() {
                          widget.currentView = CurrentView.map;
                        });
                      },
                icon: Icon(
                  Icons.location_pin,
                  color: widget.currentView == CurrentView.map
                      ? Colors.green
                      : Colors.black,
                )),
            divider(horizontal: true),
            IconButton(
                tooltip: 'Asset View',
                onPressed: widget.currentView == CurrentView.asset
                    ? null
                    : () async {
                        setState(() {
                          widget.currentView = CurrentView.asset;
                        });
                        await _loadData();
                      },
                icon: Icon(
                  Icons.view_comfy_alt_rounded,
                  color: widget.currentView == CurrentView.asset
                      ? Colors.green
                      : Colors.black,
                )),
            divider(horizontal: true),
            IconButton(
                tooltip: 'Data Grid View',
                onPressed: widget.currentView == CurrentView.grid
                    ? null
                    : () async {
                        setState(() {
                          widget.currentView = CurrentView.grid;
                        });
                        await _loadData();
                      },
                icon: Icon(
                  Icons.view_compact_outlined,
                  color: widget.currentView == CurrentView.grid
                      ? Colors.green
                      : Colors.black,
                )),
            divider(horizontal: true),
            IconButton(
                tooltip: 'reload data',
                onPressed: () async {
                  search = '*';
                  switch (widget.currentView) {
                    case CurrentView.home:
                      await _load();
                      break;
                    case CurrentView.map:
                      if (null != mapViewKey.currentState) {
                        await mapViewKey.currentState!._load();
                      }
                      break;
                    case CurrentView.asset:
                      if (null != assetViewKey.currentState) {
                        await assetViewKey.currentState!._load();
                      }
                      break;
                    case CurrentView.grid:
                      if (null != dataGridKey.currentState) {
                        await dataGridKey.currentState!.load(search: search);
                      }
                      break;
                  }
                },
                icon: const Icon(Icons.refresh)),
            divider(horizontal: true),
            SizedBox(
              height: 40,
              width: 350,
              child: SearchBar(
                leading: const Icon(Icons.search),
                hintText: 'search',
                onChanged: (value) async {
                  search = value;
                  if (search.isEmpty) {
                    search = '*';
                  }
                  switch (widget.currentView) {
                    case CurrentView.home:
                      await _load();
                      break;
                    case CurrentView.map:
                      await mapViewKey.currentState!._load();
                      break;
                    case CurrentView.asset:
                      await assetViewKey.currentState!._load();
                      break;
                    case CurrentView.grid:
                      await dataGridKey.currentState!.load(search: search);
                      break;
                  }
                },
              ),
            ),
            divider(horizontal: true),
          ],
        ),
        if (widget.currentView == CurrentView.home)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _InfraCardView(
                page: widget,
                state: this,
              ),
            ),
          ),
        if (widget.currentView == CurrentView.map)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _InfraMapView(
                key: mapViewKey,
                page: widget,
                state: this,
              ),
            ),
          ),
        if (widget.currentView == CurrentView.asset)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _InfraAssetView(
                key: assetViewKey,
                page: widget,
                state: this,
              ),
            ),
          ),
        if (widget.currentView == CurrentView.grid)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DataGridSnippet(
                filterType: FilterType.none,
                key: dataGridKey,
              ),
            ),
          ),
      ],
    );
  }
}

class _InfraCardView extends StatefulWidget {
  final InfraPage page;
  final _InfraPageState state;

  const _InfraCardView({required this.page, required this.state});

  @override
  State<_InfraCardView> createState() => _InfraCardViewState();
}

class _InfraCardViewState extends State<_InfraCardView> {
  @override
  Widget build(BuildContext context) {
    late final int count;

    switch (widget.page.type) {
      case TwinInfraType.premise:
        count = widget.state._premises.length;
        break;
      case TwinInfraType.facility:
        count = widget.state._facilities.length;
        break;
      case TwinInfraType.floor:
        count = widget.state._floors.length;
        break;
      case TwinInfraType.asset:
        count = widget.state._assets.length;
        break;
      case TwinInfraType.device:
        count = widget.state._devices.length;
        break;
    }

    if (count <= 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
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

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        switch (widget.page.type) {
          case TwinInfraType.premise:
            return PremiseInfraCard(
              premise: widget.state._premises[index],
            );
          case TwinInfraType.facility:
            return FacilityInfraCard(
              facility: widget.state._facilities[index],
            );
          case TwinInfraType.floor:
            return FloorInfraCard(
              floor: widget.state._floors[index],
            );
          case TwinInfraType.asset:
            return AssetInfraCard(
              asset: widget.state._assets[index],
            );
          case TwinInfraType.device:
            return DeviceInfraCard(
              device: widget.state._devices[index],
            );
        }
      },
    );
  }
}

class _InfraMapView extends StatefulWidget {
  final InfraPage page;
  final _InfraPageState state;

  const _InfraMapView({super.key, required this.page, required this.state});

  @override
  State<_InfraMapView> createState() => _InfraMapViewState();
}

class _InfraMapViewState extends BaseState<_InfraMapView> {
  final List<Marker> _markers = [];
  late final Icon pin;

  @override
  void setup() async {
    await _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    _markers.clear();
    execute(() async {
      final Map<dynamic, GeoLocation> locations = {};
      switch (widget.page.type) {
        case TwinInfraType.premise:
          pin = const Icon(
            Icons.home,
            color: Colors.green,
          );
          for (var e in widget.state._premises) {
            if (null != e.location) {
              locations[e] = e.location!;
            }
          }
          debugPrint('${locations.length} geo premises found');
          break;
        case TwinInfraType.facility:
          pin = const Icon(
            Icons.business,
            color: Colors.green,
          );
          for (var e in widget.state._facilities) {
            if (null != e.location) {
              locations[e] = e.location!;
            }
          }
          debugPrint('${locations.length} geo facilities found');
          break;
        case TwinInfraType.floor:
          pin = const Icon(
            Icons.cabin,
            color: Colors.green,
          );
          for (var e in widget.state._floors) {
            if (null != e.location) {
              locations[e] = e.location!;
            }
          }
          debugPrint('${locations.length} geo floors found');
          break;
        case TwinInfraType.asset:
          pin = const Icon(
            Icons.view_comfy,
            color: Colors.green,
          );
          for (var e in widget.state._assets) {
            if (null != e.location) {
              locations[e] = e.location!;
            }
          }
          debugPrint('${locations.length} geo assets found');
          break;
        case TwinInfraType.device:
          pin = const Icon(
            Icons.view_compact_sharp,
            color: Colors.green,
          );
          for (var e in widget.state._devices) {
            if (null != e.geolocation) {
              locations[e] = e.geolocation!;
            }
          }
          debugPrint('${locations.length} geo devices found');
          break;
      }

      locations.forEach((entity, value) {
        if (value.coordinates.length >= 2) {
          _markers.add(Marker(
              width: 200,
              height: 60,
              point: LatLng(value.coordinates[1], value.coordinates[0]),
              child: Tooltip(
                message: entity.name,
                child: InkWell(
                  onTap: () async {
                    showDialog(
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          switch (widget.page.type) {
                            case TwinInfraType.premise:
                              return AlertDialog(
                                content: SizedBox(
                                  width: 500,
                                  height: 500,
                                  child: PremiseInfraCard(
                                    premise: entity,
                                    popOnSelect: true,
                                  ),
                                ),
                              );
                            case TwinInfraType.facility:
                              return AlertDialog(
                                content: SizedBox(
                                  width: 500,
                                  height: 500,
                                  child: FacilityInfraCard(
                                    facility: entity,
                                    popOnSelect: true,
                                  ),
                                ),
                              );
                            case TwinInfraType.floor:
                              return AlertDialog(
                                content: SizedBox(
                                  width: 500,
                                  height: 500,
                                  child: FloorInfraCard(
                                    floor: entity,
                                    popOnSelect: true,
                                  ),
                                ),
                              );
                            case TwinInfraType.asset:
                              return AlertDialog(
                                content: SizedBox(
                                  width: 500,
                                  height: 500,
                                  child: AssetInfraCard(
                                    asset: entity,
                                    popOnSelect: true,
                                  ),
                                ),
                              );
                            case TwinInfraType.device:
                              return AlertDialog(
                                content: SizedBox(
                                  width: 500,
                                  height: 500,
                                  child: DeviceInfraCard(
                                    device: entity,
                                    popOnSelect: true,
                                  ),
                                ),
                              );
                          }
                        });
                  },
                  child: Column(
                    children: [
                      pin,
                      Text(
                        entity.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              )));
        }
      });

      refresh();
    });
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        //initialCenter: LatLng(51.5, -0.09),
        initialZoom: 3,
        //onTap: (_, p) => setState(() => customMarkers.add(buildPin(p))),
        interactionOptions: InteractionOptions(),
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(
          markers: _markers,
          rotate: false,
          alignment: Alignment.topCenter,
        ),
      ],
    );
  }
}

class _InfraAssetView extends StatefulWidget {
  final InfraPage page;
  final _InfraPageState state;

  const _InfraAssetView({super.key, required this.page, required this.state});

  @override
  State<_InfraAssetView> createState() => _InfraAssetViewState();
}

class _InfraAssetViewState extends BaseState<_InfraAssetView> {
  final List<String> _assetIds = [];

  @override
  void setup() {
    _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      _assetIds.clear();

      var aRes = await UserSession.twin.getReportedAssetIds(
          apikey: UserSession().getAuthToken(), size: 10000);

      if (validateResponse(aRes)) {
        _assetIds.addAll(aRes.body!.values);
      }
    });
    debugPrint('Reported Assets: ${_assetIds.length}');
    loading = false;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_assetIds.isEmpty) {
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

    return SafeArea(
        child: SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        children: _assetIds.map((e) {
          return SizedBox(
            width: 480,
            height: 380,
            child: Card(
              elevation: 10,
              child: DefaultAssetView(
                twinned: UserSession.twin,
                assetId: e,
                authToken: UserSession().getAuthToken(),
                onAssetDoubleTapped: (DeviceData data) async {},
                onAssetAnalyticsTapped: (String field, DeviceModel deviceModel,
                    DeviceData data) async {
                  //Navigator.pop(context);
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FieldAnalyticsPage(
                                fields: [field],
                                deviceModel: deviceModel,
                                deviceData: data,
                                canDeleteRecord: UserSession().isAdmin(),
                              )));
                },
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }
}
