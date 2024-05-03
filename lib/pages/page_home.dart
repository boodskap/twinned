import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/ui.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:twinned/pages/dashboard/page_analytics.dart';
import 'package:twinned/pages/dashboard/page_dashboad.dart';
import 'package:twinned/pages/dashboard/page_devices_view.dart';
import 'package:twinned/pages/dashboard/page_infra.dart';
import 'package:twinned/pages/dashboard/page_map.dart';
import 'package:twinned/pages/dashboard/page_mydevices.dart';
import 'package:twinned/pages/dashboard/page_myfilters.dart';
import 'package:twinned/pages/dashboard/page_myreports.dart';
import 'package:twinned/pages/dashboard/page_profileuser.dart';
import 'package:twinned/pages/dashboard/page_roles.dart';
import 'package:twinned/pages/dashboard/page_users.dart';
import 'package:twinned/pages/page_event.dart';
import 'package:twinned/pages/page_lookup.dart';
import 'package:twinned/pages/page_subscriptions.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyHomePage(
      title: '',
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  SelectedPage _selectedIndex = SelectedPage.myHome;
  final GlobalKey<ConvexAppBarState> _appBarKey =
      GlobalKey<ConvexAppBarState>();
  final int _subIndex = 0;
  List<dynamic>? menuData;
  String appVersion = '';
  String appBuildNumber = '';

  @override
  void setup() async {
    execute(() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
        appBuildNumber = packageInfo.buildNumber;
      });
    });
  }

  Widget _getPageAt(SelectedPage index) {
    switch (index) {
      case SelectedPage.myHome:
        return InfraPage(
          key: Key(const Uuid().v4()),
          type: TwinInfraType.premise,
          currentView: CurrentView.grid,
        );
      case SelectedPage.myDevices:
        return MyDevicesPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.myFilters:
        return MyFiltersPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.myReports:
        return MyReportsPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.adminDevices:
        return DevicesViewPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.adminAnalytics:
        return AnalyticsPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.adminGridView:
        return GridViewPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.mapView:
        return MapViewPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.myEvents:
        return EventPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.subscription:
        return SubscriptionsPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.myProfile:
        return TwinnedProfilePage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.roles:
        return TwinnedRolePage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.users:
        return TwinnedUserPage(
          key: Key(const Uuid().v4()),
        );
      case SelectedPage.lookup:
        return TwinnedLookupPage(
          key: Key(const Uuid().v4()),
        );
      default:
        return Text('Page: $index');
    }
  }

  void _onItemTapped(SelectedPage index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String subTitle;

    switch (_selectedIndex) {
      case SelectedPage.myHome:
        subTitle = 'Home';
        break;
      case SelectedPage.myDevices:
        subTitle = 'My Devices';
        break;
      case SelectedPage.myFilters:
        subTitle = 'Filters';
        break;
      case SelectedPage.myReports:
        subTitle = 'Reports';
        break;
      case SelectedPage.adminDevices:
        subTitle = 'All Devices';
        break;
      case SelectedPage.adminAnalytics:
        subTitle = 'Analytics';
        break;
      case SelectedPage.adminGridView:
        subTitle = 'Grid View';
        break;
      case SelectedPage.mapView:
        subTitle = 'Map View';
        break;
      case SelectedPage.myEvents:
        subTitle = 'Events';
        break;
      case SelectedPage.subscription:
        subTitle = 'Subscription';
        break;
      case SelectedPage.myProfile:
        subTitle = 'My Profile';
        break;
      case SelectedPage.roles:
        subTitle = "Roles";
        break;
      case SelectedPage.users:
        subTitle = "Users";
        break;
      case SelectedPage.lookup:
        subTitle = 'Lookup Table';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F65AD),
        toolbarHeight: 50,
        centerTitle: true,
        title: Text(
          'Digital Twin - $subTitle',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0XFFFFFFFF),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/images/logo-large.png'),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              UI().logout(context);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Center(
        child: _getPageAt(_selectedIndex),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            key: Key(const Uuid().v4()),
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo-large.png'),
                  ),
                ),
                // otherAccountsPictures: [Icon(Icons.person)],
                accountName: Text(''),
                accountEmail: Text(''),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: _selectedIndex == SelectedPage.myHome,
                onTap: () {
                  _onItemTapped(SelectedPage.myHome);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.devices_other),
                title: const Text(
                  'My Devices',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: _selectedIndex == SelectedPage.myDevices,
                onTap: () {
                  _onItemTapped(SelectedPage.myDevices);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_alt_sharp),
                title: const Text(
                  'Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: _selectedIndex == SelectedPage.myFilters,
                onTap: () {
                  _onItemTapped(SelectedPage.myFilters);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text(
                  'Reports',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: _selectedIndex == SelectedPage.myReports,
                onTap: () {
                  _onItemTapped(SelectedPage.myReports);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text(
                  'Events',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: _selectedIndex == SelectedPage.myEvents,
                onTap: () {
                  _onItemTapped(SelectedPage.myEvents);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.subscriptions_sharp),
                title: const Text(
                  'Subscriptions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: _selectedIndex == SelectedPage.subscription,
                onTap: () {
                  _onItemTapped(SelectedPage.subscription);
                  Navigator.pop(context);
                },
              ),
              if (UserSession().loginResponse!.user.email != 'try@boodskap.io')
                ListTile(
                  leading: const Icon(Icons.person_2_sharp),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: _selectedIndex == SelectedPage.myProfile,
                  onTap: () {
                    _onItemTapped(SelectedPage.myProfile);
                    Navigator.pop(context);
                  },
                ),
              if (menuData != null)
                for (var menu in menuData!)
                  if (menu != null &&
                      menu.menus != null &&
                      (menu.menus as List).isNotEmpty)
                    _buildExpansionTile(context, menu),
              if (UserSession().isAdmin())
                ExpansionTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text(
                    'Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onExpansionChanged: (bool isExpanded) {},
                  initiallyExpanded: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: ListTile(
                        leading: const Icon(Icons.devices_other),
                        title: const Text(
                          'Devices',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: _selectedIndex == SelectedPage.adminDevices,
                        onTap: () {
                          _onItemTapped(SelectedPage.adminDevices);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: ListTile(
                        leading: const Icon(Icons.analytics_rounded),
                        title: const Text(
                          'Analytics',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: _selectedIndex == SelectedPage.adminAnalytics,
                        onTap: () {
                          _onItemTapped(SelectedPage.adminAnalytics);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: ListTile(
                        leading: const Icon(Icons.grid_view),
                        title: const Text(
                          'Grid View',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: _selectedIndex == SelectedPage.adminGridView,
                        onTap: () {
                          _onItemTapped(SelectedPage.adminGridView);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: ListTile(
                        leading: const Icon(Icons.location_on_rounded),
                        title: const Text(
                          'Map View',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: _selectedIndex == SelectedPage.mapView,
                        onTap: () {
                          _onItemTapped(SelectedPage.mapView);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.manage_search),
                      title: const Text(
                        'Lookup Table',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: _selectedIndex == SelectedPage.lookup,
                      onTap: () {
                        _onItemTapped(SelectedPage.lookup);
                        Navigator.pop(context);
                      },
                    ),
                    ExpansionTile(
                        leading: const Icon(Icons.verified_user),
                        title: const Text(
                          'User Management',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onExpansionChanged: (bool isExpanded) {},
                        initiallyExpanded: false,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: ListTile(
                              leading: const Icon(Icons.manage_accounts),
                              title: const Text(
                                'Roles',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: _selectedIndex == SelectedPage.roles,
                              onTap: () {
                                _onItemTapped(SelectedPage.roles);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: ListTile(
                              leading: const Icon(Icons.supervised_user_circle),
                              title: const Text(
                                'User',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: _selectedIndex == SelectedPage.users,
                              onTap: () {
                                _onItemTapped(SelectedPage.users);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ]),
                  ],
                ),
              const Divider(),
              ListTile(
                iconColor: Colors.black,
                textColor: Colors.black,
                leading: const Icon(Icons.logout),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  UI().logout(context);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Boodskap Digital Twin\nVersion:$appVersion\nBuild:$appBuildNumber',
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, dynamic menu) {
    if ((menu.displayName ?? '').isNotEmpty &&
        menu.menus != null &&
        (menu.menus as List).isNotEmpty) {
      return ExpansionTile(
        leading: const Icon(Icons.admin_panel_settings),
        title: Text(
          menu.displayName ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        onExpansionChanged: (bool isExpanded) {},
        initiallyExpanded: true,
        children: [
          for (var subMenu in menu.menus as List)
            if (subMenu != null && (subMenu.displayName ?? '').isNotEmpty)
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    subMenu.displayName ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                selected: _selectedIndex == 1 && _subIndex == 0,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
        ],
      );
    } else {
      return Container();
    }
  }
}

enum SelectedPage {
  myHome,
  myDevices,
  myFilters,
  myReports,
  adminDevices,
  adminAnalytics,
  adminGridView,
  myEvents,
  myProfile,
  mapView,
  subscription,
  users,
  roles,
  lookup
}
