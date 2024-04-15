import 'package:flutter/material.dart';
import 'package:twinned/pages/dashboardmenu/meni_items.dart';
import 'package:twinned/pages/dashboardmenu/menugroup_add.dart';

class DashboardMenuPage extends StatefulWidget {
  const DashboardMenuPage({super.key});

  @override
  State<DashboardMenuPage> createState() => _DashboardMenuPageState();
}

class _DashboardMenuPageState extends State<DashboardMenuPage> {
  List<Widget> containers = [];
  // final List<String> _types = ['SCREEN', 'PAGE'];
  late Image bannerImage;
  bool isvisible = false;

  @override
  void initState() {
    super.initState();
    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: bannerImage,
          ),
          MenuGroupAdd(
            addMenuGroup: (cleared) {
              setState(() {
                isvisible = true;
              });
            },
          ),
          const SizedBox(height: 10),
          isvisible != true
              ? Column(
                  children: [
                    Container(
                      width: 600,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.grey),top: BorderSide(color: Colors.grey), right: BorderSide(color: Colors.grey)),
                        color: Color.fromARGB(242, 253, 247, 235),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      child:const Center(child: Text('Menu Group Items',style: TextStyle(fontWeight: FontWeight.bold),)),
                    ),
                    const MenuItems(),
                  ],
                )
              : const Text('Add yours')
        ],
      ),
    );
  }
}
