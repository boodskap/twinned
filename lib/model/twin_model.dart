import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/widgets/common/busy_indicator.dart';
import 'package:twinned/widgets/commons/tag_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;

enum ComponentType { deviceModel, device, assetModel }

typedef BasicInfoCallback = void Function(
    String name, String? description, String? tags);

class TwinModel extends StatefulWidget {
  final ComponentType controlType;
  final double width;
  final double height;

  const TwinModel({
    super.key,
    required this.controlType,
    this.width = 200,
    this.height = 200,
  });

  @override
  State<TwinModel> createState() => _TwinModelState();
}

class _TwinModelState extends BaseState<TwinModel> {
  final List<Widget> _cards = [];
  String? _search = '*';
  twinned.DeviceModel? model;
  twinned.Device? device;
  twinned.AssetModel? assetModel;
  List<twinned.Lookup> settingList = [];
  @override
  void setup() async {
    await load();
  }

  void help() {
    late final String title;

    switch (widget.controlType) {
      case ComponentType.deviceModel:
        title = 'Device Library';
        break;
      case ComponentType.device:
        title = 'Installation Database';
        break;
      case ComponentType.assetModel:
        title = 'Asset Library';
        break;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.help),
            title: Text(title),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.blue),
                  ))
            ],
          );
        });
  }

  Future load() async {
    if (loading) {
      debugPrint('already loading.. skipped');
      return;
    }

    debugPrint('Loading ${widget.controlType}...');
    loading = true;

    switch (widget.controlType) {
      case ComponentType.deviceModel:
        await _loadDeviceModels();
        break;

      case ComponentType.device:
        await _loadDevices();
        break;
      case ComponentType.assetModel:
        await _loadAssetModels();
        break;
      default:
        break;
    }
    loading = false;
  }

  void _buildCard(String name, List<twinned.Lookup> settingData,
      List<Widget> cards, String type, twinned.DeviceModel dmodelData) {
    settingList = [];
    settingList = settingData;

    Widget tagSection = Center(
      child: SizedBox(
          height: 150,
          child: SingleChildScrollView(
              child: TagList(
            tagDataList: settingList,
            onSave: (value) {
              _updateDeviceModels(value, dmodelData);
            },
          ))),
    );
    Widget newCard = CardSection(
      cardHeight: widget.height,
      cardWidth: widget.width,
      name: name,
      tagChild: tagSection,
    );
    cards.add(newCard);
  }

  void _buildDeviceCard(String name, List<twinned.Lookup> settingData,
      List<Widget> cards, String type, twinned.Device deviceData) {
    settingList = [];
    settingList = settingData;

    Widget tagSection = Center(
      child: SizedBox(
          height: 150,
          child: SingleChildScrollView(
              child: TagList(
            tagDataList: settingList,
            onSave: (value) {
              _updateDevice(value, deviceData);
            },
          ))),
    );
    Widget newCard = CardSection(
      cardHeight: widget.height,
      cardWidth: widget.width,
      name: name,
      tagChild: tagSection,
    );
    cards.add(newCard);
  }

  void _buildAssetCard(String name, List<twinned.Lookup> settingData,
      List<Widget> cards, String type, twinned.AssetModel assetData) {
    settingList = [];
    settingList = settingData;

    Widget tagSection = Center(
      child: SizedBox(
          height: 150,
          child: SingleChildScrollView(
              child: TagList(
            tagDataList: settingList,
            onSave: (value) {
              _updateAssetModel(value, assetData);
            },
          ))),
    );
    Widget newCard = CardSection(
      cardHeight: widget.height,
      cardWidth: widget.width,
      name: name,
      tagChild: tagSection,
    );
    cards.add(newCard);
  }

  Future _updateDeviceModels(
      List<twinned.Lookup> settingsData, twinned.DeviceModel dmodelData) async {
    var res = await UserSession.twin.updateDeviceModel(
        apikey: UserSession().getAuthToken(),
        modelId: dmodelData.id,
        body: twinned.DeviceModelInfo(
            name: dmodelData.name,
            description: dmodelData.description,
            make: dmodelData.make,
            model: dmodelData.model,
            version: dmodelData.version,
            tags: dmodelData.tags,
            banners: dmodelData.banners,
            images: dmodelData.images,
            selectedBanner: dmodelData.selectedBanner,
            selectedImage: dmodelData.selectedImage,
            preprocessorId: dmodelData.preprocessorId,
            parameters: dmodelData.parameters,
            customSettings: dmodelData.customSettings ?? [],
            customWidget: dmodelData.customWidget,
            makePublic: dmodelData.makePublic,
            movable: dmodelData.movable,
            metadata: dmodelData.metadata,
            icon: dmodelData.icon,
            hasGeoLocation: dmodelData.hasGeoLocation,
            defaultView: dmodelData.defaultView));

    if (validateResponse(res)) {
      Navigator.pop(context);
      alert('Success', 'Device model setting changes updated successfully');
      await load();
    }
  }

  Future _updateDevice(
      List<twinned.Lookup> settingsData, twinned.Device deviceData) async {
    var dRes = await UserSession.twin.updateDevice(
        apikey: UserSession().getAuthToken(),
        deviceId: deviceData.id,
        body: twinned.DeviceInfo(
          name: deviceData.name,
          modelId: deviceData.modelId,
          deviceId: deviceData.deviceId,
          description: deviceData.description,
          banners: deviceData.banners,
          images: deviceData.images,
          selectedBanner: deviceData.selectedBanner,
          selectedImage: deviceData.selectedImage,
          tags: deviceData.tags,
          icon: deviceData.icon,
          hasGeoLocation: deviceData.hasGeoLocation,
          movable: deviceData.movable,
          geolocation: deviceData.geolocation,
          customWidget: deviceData.customWidget,
          defaultView: deviceData.defaultView,
          metadata: deviceData.metadata,
        ));

    if (validateResponse(dRes)) {
      Navigator.pop(context);
      alert('Success', 'Device setting changes updated successfully');
      await load();
    }
  }

  Future _updateAssetModel(
      List<twinned.Lookup> settingsData, twinned.AssetModel assetData) async {
    var aRes = await UserSession.twin.updateAssetModel(
        apikey: UserSession().getAuthToken(),
        assetModelId: assetData.id,
        body: twinned.AssetModelInfo(
          name: assetData.name,
          description: assetData.description,
          tags: assetData.tags,
          icon: assetData.icon,
          images: assetData.images,
          selectedImage: assetData.selectedImage,
          banners: assetData.banners,
          geolocation: assetData.geolocation,
          hasGeoLocation: assetData.hasGeoLocation,
          metadata: assetData.metadata,
          movable: assetData.movable,
          selectedBanner: assetData.selectedBanner,
          deviceModelsIds: assetData.deviceModelsIds ?? [],
        ));

    if (validateResponse(aRes)) {
      Navigator.pop(context);
      alert('Success', 'Asset Model setting changes updated successfully');
      await load();
    }
  }

  Future _loadDeviceModels() async {
    await execute(() async {
      List<Widget> cards = [];

      var r = await UserSession.twin.searchDeviceModels(
          apikey: UserSession().getAuthToken(),
          body: twinned.SearchReq(page: 0, size: 25, search: _search ?? '*'));
      if (validateResponse(r)) {
        if (r.body!.values!.isNotEmpty) {
          for (twinned.DeviceModel e in r.body!.values!) {
            model = e;
            _buildCard(e.name, [], cards, "DeviceModel", e);
          }
        }
      }
      refresh(sync: () {
        _cards.clear();
        _cards.addAll(cards);
      });
    });
  }

  Future _loadAssetModels() async {
    await execute(() async {
      List<Widget> cards = [];

      var r = await UserSession.twin.searchAssetModels(
          apikey: UserSession().getAuthToken(),
          body: twinned.SearchReq(page: 0, size: 25, search: _search ?? '*'));
      if (validateResponse(r)) {
        if (r.body!.values!.isNotEmpty) {
          for (twinned.AssetModel e in r.body!.values!) {
            assetModel = e;
            _buildAssetCard(e.name, [], cards, "AssetModel", e);
          }
        }
      }
      refresh(sync: () {
        _cards.clear();
        _cards.addAll(cards);
      });
    });
  }

  Future _loadDevices() async {
    await execute(() async {
      final List<Widget> cards = [];

      var r = await UserSession.twin.searchDevices(
          apikey: UserSession().getAuthToken(),
          body: twinned.SearchReq(page: 0, size: 25, search: _search ?? '*'));
      if (validateResponse(r)) {
        for (twinned.Device e in r.body!.values!) {
          // device = e;
          device = r.body!.values![0];
          _buildDeviceCard(e.name, [], cards, "Device", e);
        }
      }
      refresh(sync: () {
        _cards.clear();
        _cards.addAll(cards);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              divider(horizontal: true),
              const BusyIndicator(),
              divider(horizontal: true),
              IconButton(
                  onPressed: () async {
                    await load();
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh)),
              divider(horizontal: true),
              SizedBox(
                width: 250,
                height: 30,
                child: SearchBar(
                    leading: const Icon(Icons.search),
                    onChanged: (search) async {
                      _search = search;
                      await load();
                    }),
              ),
            ],
          ),
          if (_cards.isEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: const Center(child: Text(('No data found'))),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _cards,
            ),
          )
        ],
      ),
    );
  }
}

class CardSection extends StatefulWidget {
  final double cardWidth;
  final double cardHeight;
  final String name;
  final Widget tagChild;
  const CardSection(
      {super.key,
      required this.cardWidth,
      required this.cardHeight,
      required this.name,
      required this.tagChild});

  @override
  State<CardSection> createState() => _CardSectionState();
}

class _CardSectionState extends State<CardSection> {
  ImageProvider? image = const AssetImage('images/setting-icon.png');
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        width: widget.cardWidth,
        height: widget.cardHeight,
        color: Colors.white,
        child: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(image: image!),
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                            fontSize: 14, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              widget.tagChild
            ],
          ),
        ),
      ),
    );
  }
}
