import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/ui.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:twinned/widgets/commons/datagrid_snippet.dart';

class DeviceModelGridPage extends StatefulWidget {
  final String title;
  final DataGridSnippet child;
  const DeviceModelGridPage(
      {super.key, required this.title, required this.child});

  @override
  State<DeviceModelGridPage> createState() => _DeviceModelGridPageState();
}

class _DeviceModelGridPageState extends State<DeviceModelGridPage> {
  late Widget bannerImage;

  @override
  void initState() {
    if (null != twinSysInfo && twinSysInfo!.bannerImage!.isNotEmpty) {
      bannerImage = UserSession()
          .getImage(domainKey, twinSysInfo!.bannerImage!, fit: BoxFit.cover);
    } else {
      bannerImage = Image.asset(
        'assets/images/ldashboard_banner.png',
        fit: BoxFit.cover,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F65AD),
        centerTitle: true,
        leading: const BackButton(
          color: Color(0XFFFFFFFF),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0XFFFFFFFF),
          ),
        ),
        actions: <Widget>[
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
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: bannerImage,
          ),
          Flexible(child: widget.child)
        ],
      ),
    );
  }
}
