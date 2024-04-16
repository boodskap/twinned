import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:nocode_commons/widgets/default_assetview.dart';
import 'package:twinned/pages/dashboard/page_device_history.dart';
import 'package:twinned/pages/widgets/asset_infra_card.dart';
import 'package:twinned/pages/widgets/device_infra_card.dart';
import 'package:twinned/pages/widgets/facility_infra_card.dart';
import 'package:twinned/pages/widgets/floor_infra_card.dart';
import 'package:twinned/pages/widgets/premise_infra_card.dart';
import 'package:twinned/providers/state_provider.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:data_table_2/data_table_2.dart';
import 'package:twinned_widgets/twinned_widgets.dart' as widgets;

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

  final GlobalKey<_InfraMapViewState> mapViewKey = GlobalKey();
  final GlobalKey<_InfraGridViewState> gridViewKey = GlobalKey();
  final GlobalKey<_InfraAssetViewState> assetViewKey = GlobalKey();

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
        setState(() {
          _data.addAll(data);
        });
      }
    });

    loading = false;
  }

  Future _load() async {
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
                      if (null != gridViewKey.currentState) {
                        await gridViewKey.currentState!._load();
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
                      await gridViewKey.currentState!._load();
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
              child: _InfraGridView(
                key: gridViewKey,
                page: widget,
                state: this,
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
                onAssetDoubleTapped: (DeviceData dd) async {},
                onAssetAnalyticsTapped: (DeviceData dd) async {},
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }
}

class _InfraGridView extends StatefulWidget {
  final InfraPage page;
  final _InfraPageState state;

  const _InfraGridView({super.key, required this.page, required this.state});

  @override
  State<_InfraGridView> createState() => _InfraGridViewState();
}

class _InfraGridViewState extends BaseState<_InfraGridView> {
  final List<DeviceData> _data = [];
  final Map<String, DeviceModel> _models = {};

  @override
  void setup() {
    _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      _data.clear();
      _models.clear();

      var dRes = await UserSession.twin.searchRecentDeviceData(
          apikey: UserSession().getAuthToken(),
          body: FilterSearchReq(
              search: widget.state.search, page: 0, size: 1000));

      if (validateResponse(dRes)) {
        _data.addAll(dRes.body!.values!);

        List<String> modelIds = [];

        for (DeviceData dd in _data) {
          if (modelIds.contains(dd.modelId)) continue;
          modelIds.add(dd.modelId);
        }

        var mRes = await UserSession.twin.getDeviceModels(
            apikey: UserSession().getAuthToken(), body: GetReq(ids: modelIds));

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

  Widget _buildTable() {
    List<DataColumn2> columns = [];
    List<DataRow2> rows = [];

    columns.addAll([
      const DataColumn2(
        label: Text(
          'Asset',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn2(
        label: Text(
          'Device',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn2(
        label: Text(
          'Last Reported',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn2(
        label: Text(
          'Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn2(
          label: const Center(
              child: Text(
            'Sensor Data',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          fixedWidth: MediaQuery.of(context).size.width / 2),
    ]);

    for (var dd in _data) {
      var dT = DateTime.fromMillisecondsSinceEpoch(dd.updatedStamp);
      List<Widget> children = [];
      Map<String, dynamic> dynData = dd.data as Map<String, dynamic>;
      DeviceModel deviceModel = _models[dd.modelId]!;
      List<String> fields = NoCodeUtils.getSortedFields(deviceModel);
      for (String field in fields) {
        widgets.SensorWidgetType type =
            NoCodeUtils.getSensorWidgetType(field, _models[dd.modelId]!);
        if (type == widgets.SensorWidgetType.none) {
          String iconId = NoCodeUtils.getParameterIcon(field, deviceModel);
          children.add(Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                NoCodeUtils.getParameterLabel(field, deviceModel),
                style: const TextStyle(
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold),
              ),
              if (iconId.isNotEmpty)
                SizedBox(
                    width: 48,
                    height: 48,
                    child: UserSession().getImage(dd.domainKey, iconId)),
              Text(
                '${dynData[field] ?? '-'} ${NoCodeUtils.getParameterUnit(field, deviceModel)}',
                style: const TextStyle(
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ));
        } else {
          Parameter? parameter =
              NoCodeUtils.getParameter(field, _models[dd.modelId]!);
          children.add(SizedBox(
              width: 160,
              height: 160,
              child: widgets.SensorWidget(
                parameter: parameter!,
                deviceData: dd,
                deviceModel: deviceModel,
                tiny: true,
              )));
        }
      }

      rows.add(DataRow2(cells: [
        DataCell(InkWell(
          onTap: () {},
          child: Text(
            dd.asset ?? '-',
            style: const TextStyle(
                color: Colors.blue,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold),
          ),
        )),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
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
                          fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            Tooltip(
              message: 'Device Model',
              child: Text(
                dd.modelName ?? '-',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis, fontSize: 12),
              ),
            ),
            Tooltip(
              message: 'Description',
              child: Text(
                dd.modelDescription ?? '-',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis, fontSize: 12),
              ),
            ),
          ],
        )),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeago.format(dT, locale: 'en'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              dT.toString(),
            ),
          ],
        )),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tooltip(
              message: 'Premise',
              child: Text(
                dd.premise ?? '-',
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Tooltip(
              message: 'Facility',
              child: Text(
                dd.facility ?? '-',
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ),
            Tooltip(
              message: 'Floor',
              child: Text(
                dd.floor ?? '-',
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        )),
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        )),
      ]));
    }

    return DataTable2(
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
