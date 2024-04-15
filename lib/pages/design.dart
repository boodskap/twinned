import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/widgets/alarm_snippet.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;

class DesignPage extends StatefulWidget {
  final twinned.Device? device;
  final twinned.DeviceModel? deviceModel;
  final bool? liveData;
  final bool? showTitle;
  final double? topMenuHeight;
  final double? leftMenuWidth;
  final double? rightMenuWidth;
  final double? bottomMenuHeight;
  final double? width;
  final double? height;

  const DesignPage({
    super.key,
    this.device,
    this.deviceModel,
    this.liveData = true,
    this.showTitle = true,
    this.topMenuHeight = 45,
    this.bottomMenuHeight = 45,
    this.leftMenuWidth = 45,
    this.rightMenuWidth = 45,
    this.width = 350,
    this.height = 350,
  });

  @override
  State<DesignPage> createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.red,
          child: const Center(
            child: SizedBox(
              child: Column(
                children: [
                  DeviceView(
                    topMenuHeight: 50,
                    bottomMenuHeight: 50,
                    leftMenuWidth: 50,
                    rightMenuWidth: 50,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

class DeviceView extends StatefulWidget {
  final double width;
  final double height;
  final double topMenuHeight;
  final double bottomMenuHeight;
  final double leftMenuWidth;
  final double rightMenuWidth;
  final Color topMenuBgColor;
  final Color bottomMenuBgColor;
  final Color leftMenuBgColor;
  final Color rightMenuBgColor;
  const DeviceView({
    super.key,
    this.width = 350,
    this.height = 350,
    this.topMenuHeight = 45,
    this.bottomMenuHeight = 45,
    this.leftMenuWidth = 60,
    this.rightMenuWidth = 60,
    this.topMenuBgColor = Colors.blue,
    this.bottomMenuBgColor = Colors.blue,
    this.leftMenuBgColor = Colors.yellow,
    this.rightMenuBgColor = Colors.yellow,
  });

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends BaseState<DeviceView> {
  Widget? alarms;

  @override
  void setup() async {
    var res = await UserSession.twin.getDeviceData(
        apikey: UserSession().getAuthToken(),
        deviceId: 'FFNZ01',
        isHardwareDevice: true);
    if (validateResponse(res)) {
      alarms = EvaluatedAlarmsSnippet(
        deviceData: res.body!.data!,
        spacing: 20,
        twinned: UserSession.twin,
        authToken: UserSession().getAuthToken(),
      );
      refresh();
    }
  }

  Widget _buildTopMenus(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [if (null != alarms) alarms!],
    );
  }

  Widget _buildLeftMenus(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.add)],
      ),
    );
  }

  Widget _buildCenterMenus(BuildContext context) {
    return SizedBox(height: widget.height, child: const Column());
  }

  Widget _buildRightMenus(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.add)],
      ),
    );
  }

  Widget _buildBottomMenus(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(Icons.add)],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width =
        widget.width + widget.leftMenuWidth + widget.rightMenuWidth + 100;
    double height =
        widget.height + widget.topMenuHeight + widget.bottomMenuHeight + 100;
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          if (widget.topMenuHeight > 0)
            SizedBox(
              height: widget.topMenuHeight,
              child: Container(
                color: widget.topMenuBgColor,
                child: _buildTopMenus(context),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.orange,
                  child: Row(
                    children: [
                      //Left Menu
                      if (widget.leftMenuWidth > 0)
                        SizedBox(
                          width: widget.leftMenuWidth,
                          child: Container(
                              color: widget.leftMenuBgColor,
                              child: _buildLeftMenus(context)),
                        ),
                      //Center Menu
                      Expanded(child: _buildCenterMenus(context)),
                      //Right Menu
                      if (widget.rightMenuWidth > 0)
                        SizedBox(
                          width: widget.rightMenuWidth,
                          child: Container(
                              color: widget.rightMenuBgColor,
                              child: _buildRightMenus(context)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          //Bottom Menu
          if (widget.bottomMenuHeight > 0)
            SizedBox(
              height: widget.bottomMenuHeight,
              child: Container(
                color: widget.bottomMenuBgColor,
                child: _buildBottomMenus(context),
              ),
            )
        ],
      ),
    );
  }
}
