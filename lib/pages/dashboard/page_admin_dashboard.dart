import 'package:flutter/material.dart';
import 'package:nocode_commons/core/ui.dart';
import 'package:twinned/pages/dashboard/page_dashboad.dart';
import 'package:twinned/pages/page_event.dart';
import 'package:twinned/pages/page_trigger.dart';
import 'package:uuid/uuid.dart';

class AdminDashboardPage extends StatefulWidget {
  final String title;
  const AdminDashboardPage({Key? key, required this.title}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  // final int _subIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController animationController;
  bool isDrawerOpen = false;
  late Widget _selectedPage;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
    _selectedIndex = 0;
    _selectedPage = GridViewPage(key: Key(const Uuid().v4()));
  }

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      Navigator.pop(context);
      return;
    }

    // Navigator.pop(context);

    setState(() {
      _selectedIndex = index;
      _selectedPage = _getPageAt(index);
    });
  }

  Widget _getPageAt(int index) {
    switch (index) {
      case 0:
        return GridViewPage(
          key: Key(const Uuid().v4()),
        );
      case 1:
        return EventPage(
          key: Key(const Uuid().v4()),
        );
      case 2:
        return TriggerPage(
          key: Key(const Uuid().v4()),
        );
    }
    return Text('Page: $index');
  }

  @override
  Widget build(BuildContext context) {
    String subTitle = '';
    switch (_selectedIndex) {
      case 0:
        subTitle = 'Dashboard';
        break;
      case 1:
        subTitle = 'Events';
        break;
      case 2:
        subTitle = 'Triggers';
        break;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 50,
        centerTitle: true,
        title: Text(
          'Digital Twin - $subTitle',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/images/logo-large.png'),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              UI().logout(context);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: isDrawerOpen ? 0 : -200,
            width: 230,
            child: Row(
              children: [
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: ListView(
                    children: [
                      ExpansionTile(
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        leading: const Icon(Icons.admin_panel_settings),
                        title: const Text(
                          'Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onExpansionChanged: (bool isExpanded) {},
                        initiallyExpanded: true,
                        children: [
                          ListTile(
                            title: const Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                'Dashboard',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            selected: _selectedIndex == 0,
                            onTap: () {
                              _onItemTapped(0);
                            },
                          ),
                          ListTile(
                            title: const Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                'Events',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            selected: _selectedIndex == 1,
                            onTap: () {
                              _onItemTapped(1);
                            },
                          ),
                          ListTile(
                            title: const Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                'Triggers',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            selected: _selectedIndex == 2,
                            onTap: () {
                              _onItemTapped(2);
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        leading: const Icon(Icons.settings),
                        title: const Text(
                          'Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onExpansionChanged: (bool isExpanded) {},
                        initiallyExpanded: true,
                        children: [
                          ListTile(
                            title: const Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                'Event Registration',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            selected: _selectedIndex == 3,
                            onTap: () {
                              _onItemTapped(3);
                            },
                          ),
                        ],
                      ),
                      ListTile(
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: const Icon(Icons.logout),
                        onTap: () {
                          UI().logout(context);
                        },
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    toggleDrawer();
                  },
                  child: Icon(
                    isDrawerOpen ? Icons.menu_open : Icons.menu,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: isDrawerOpen ? 210 : 0,
            right: isDrawerOpen ? 0 : -20,
            bottom: 0,
            child: _selectedPage,
          ),
        ],
      ),
    );
  }
}
