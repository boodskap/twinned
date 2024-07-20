import 'package:eventify/eventify.dart' as event;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned/pages/widgets/role_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:intl_phone_field/intl_phone_field.dart';

final TextStyle _warnTextStyle = GoogleFonts.acme(
    color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold);

final TextStyle _labelPopupTextStyle = GoogleFonts.acme(
    color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);

final TextStyle _errorPopupTextStyle = GoogleFonts.acme(
    color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold);
const Color primaryColor = Color(0xFF0C244A);
const Color secondaryColor = Color(0xFFFFFFFF);

const hdivider = SizedBox(
  width: 8,
);

class TwinnedUserPage extends StatefulWidget {
  const TwinnedUserPage({
    super.key,
  });

  @override
  State<TwinnedUserPage> createState() => _TwinnedUserPageState();
}

class _TwinnedUserPageState extends BaseState<TwinnedUserPage> {
  late Image bannerImage;
  final List<twinned.TwinUser> _entities = [];

  event.Listener? listener;
  List<TableRow> rows = [];
  List<TableRow> paramHeaders = [];
  List<String> rolesSelected = [];
  final List<twinned.TwinUser> userList = [];
  @override
  void initState() {
    super.initState();

    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );

    paramHeaders.add(TableRow(
        decoration: BoxDecoration(color: Colors.grey[300]),
        children: const [
          TableHeader(title: 'First Name'),
          TableHeader(title: 'Last Name'),
          TableHeader(title: 'Email Address'),
          TableHeader(title: 'Phone Number'),
          TableHeader(title: 'Action'),
        ]));
    rows.add(paramHeaders.first);
    _rebuild();
    listener = BaseState.layoutEvents.on(PageEvent.teamChanged.name, context,
        (ev, context) {
      setup();
    });
  }

  @override
  void setup() async {
    _loadEntities();
  }

  void _rebuild() {
    rows.clear();
    rows.add(paramHeaders.first);
    for (var p in userList) {
      _buildRow(p);
    }
    setState(() {});
  }

  void _buildRow(var param) {
    List<String> nameParts = param.name.split(' ');

    String firstName = nameParts[0]; // First name
    String lastName = nameParts.length > 1 ? nameParts[1] : '';
    rolesSelected = param.roles;
    setState(() {});

    TableRow row = TableRow(children: [
      Align(alignment: Alignment.center, child: Text(firstName)),
      Align(
        alignment: Alignment.center,
        child: Text(lastName),
      ),
      Align(alignment: Alignment.center, child: Text(param.email ?? '')),
      Align(
        alignment: Alignment.center,
        child: Text(param.phone),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Tooltip(
            message: "Roles",
            child: RolesWidget(
              currentRoles: rolesSelected,
              valueChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    rolesSelected = value;
                  });
                }
              },
              isSave: true,
              iconSize: 18,
              saveConfirm: (roleValue) {
                roleValue.removeWhere((element) => element.isEmpty);
                twinned.TwinUserInfo userinfo = twinned.TwinUserInfo(
                    name: param.name,
                    email: param.email,
                    phone: param.phone,
                    roles: roleValue);
                _updateUser(
                  param.id,
                  userinfo,
                );
                Navigator.pop(context);
              },
            ),
          ),
          Tooltip(
            message: "Edit",
            child: IconButton(
              onPressed: () {
                _showUserPopup(context, "Edit", user: param);
              },
              icon: const Icon(
                Icons.edit,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
          Tooltip(
            message: "Delete",
            child: IconButton(
              onPressed: () {
                confirmDeletion(context, param.id);
              },
              icon: const Icon(
                Icons.delete,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    ]);
    rows.add(row);
  }

  @override
  void dispose() {
    BaseState.layoutEvents.off(listener);
    super.dispose();
  }

  void _loadEntities() {
    _searchEntities("*");
  }

  void _searchEntities(String search) async {
    execute(() async {
      List<twinned.TwinUser> entities = [];

      userList.clear();
      var res = await UserSession.twin.searchTwinUsers(
        apikey: UserSession().getAuthToken(),
        body: twinned.SearchReq(page: 0, size: 100, search: search),
      );

      if (validateResponse(res)) {
        for (twinned.TwinUser r in res.body!.values!) {
          entities.add(r);
        }

        userList.addAll(entities);
      }

      refresh(sync: () {
        _entities.clear();
        _entities.addAll(entities);
        _rebuild();
      });
    });
  }

  void _addNewUser(twinned.TwinUserInfo userinfo) async {
    busy();
    try {
      var res = await UserSession.twin
          .createTwinUser(apikey: UserSession().getAuthToken(), body: userinfo);

      if (validateResponse(res)) {
        twinned.TwinUser entity = res.body!.entity!;
        _entities.add(entity);
        _loadEntities();
      }

      refresh();
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }

  void _updateUser(String userId, twinned.TwinUserInfo userinfo) async {
    busy();
    try {
      var res = await UserSession.twin.updateTwinUser(
        apikey: UserSession().getAuthToken(),
        twinUserId: userId,
        body: userinfo,
      );
      if (validateResponse(res)) {
        _loadEntities();
      }
      refresh();
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }

  _showUserPopup(BuildContext context, type, {twinned.TwinUser? user}) {
    String firstName = "";
    String lastName = "";
    String email = "";
    String phoneNumber = "";
    String roleId = "";
    if (type == "Edit") {
      List<String> nameParts = user!.name.split(' ');
      firstName = nameParts[0];
      lastName = nameParts.length > 1 ? nameParts[1] : '';
      email = user.email ?? '';
      phoneNumber = user.phone ?? "";
      roleId = user.roles!.isNotEmpty ? user.roles![0] : "";
    }

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Container(
            decoration: BoxDecoration(
              color: UserSession.getDrawerColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(user != null ? 'Update User' : 'Add User',
                      style: UserSession.getPopupTextStyle()),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: firstName,
                    onChanged: (value) {
                      firstName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter valid first name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter First Name',
                      errorStyle: _errorPopupTextStyle,
                      labelStyle: _labelPopupTextStyle,
                    ),
                  ),
                  TextFormField(
                    initialValue: lastName,
                    onChanged: (value) {
                      lastName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter valid last name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Last Name',
                      errorStyle: _errorPopupTextStyle,
                      labelStyle: _labelPopupTextStyle,
                    ),
                  ),
                  TextFormField(
                    initialValue: email,
                    enabled: user != null ? false : true,
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email cannot be empty";
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Email Address',
                      errorStyle: _errorPopupTextStyle,
                      labelStyle: _labelPopupTextStyle,
                    ),
                  ),
                  IntlPhoneField(
                    decoration: InputDecoration(
                        labelText: 'Enter Phone Number',
                        errorStyle: _errorPopupTextStyle,
                        labelStyle: _labelPopupTextStyle,
                        counterText: ""),
                    initialCountryCode: 'IN',
                    initialValue: phoneNumber,
                    onChanged: (phone) {
                      phoneNumber = phone.completeNumber;
                    },
                    invalidNumberMessage: 'Enter a valid phone number',
                    validator: (value) {
                      // ignore: prefer_is_empty
                      if (value?.number.toString().length == 0) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: UserSession.getLabelTextStyle()
                              .copyWith(color: primaryColor),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      hdivider,
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            twinned.TwinUserInfo userinfo =
                                twinned.TwinUserInfo(
                                    name: "$firstName $lastName",
                                    email: email,
                                    phone: phoneNumber,
                                    roles: user != null ? user.roles : []);

                            if (user != null) {
                              _updateUser(
                                user.id,
                                userinfo,
                              );
                            } else {
                              _addNewUser(userinfo);
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        child: Text(
                          user != null ? 'Update' : 'Submit',
                          style: UserSession.getLabelTextStyle()
                              .copyWith(color: secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  confirmDeletion(BuildContext context, String id) {
    Widget cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        minimumSize: const Size(140, 40),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        "Cancel",
        style: UserSession.getLabelTextStyle().copyWith(color: primaryColor),
      ),
    );
    Widget continueButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size(140, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        _removeEntity(id);
      },
      child: Text(
        "Delete",
        style: UserSession.getLabelTextStyle().copyWith(color: secondaryColor),
      ),
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: _warnTextStyle,
      ),
      content: Text(
        "Deleting a user can not be undone.\nYou will loose all of the user data, history, etc.\n\nAre you sure you want to delete?",
        style: _warnTextStyle,
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _removeEntity(String id) async {
    try {
      var res = await UserSession.twin
          .deleteTwinUser(apikey: UserSession().getAuthToken(), twinUserId: id);
      if (validateResponse(res)) {
        Future.delayed(const Duration(seconds: 1), () {
          _loadEntities();
        });
      }
    } catch (e, s) {
      debugPrint('e');
      debugPrint('$s');
    }
  }

  @override
  Widget build(BuildContext context) {
    const divider = SizedBox(
      width: 10,
      height: 5,
    );
    return Column(
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: bannerImage),
        divider,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // const BusyIndicator(),
            // divider,
            // Tooltip(
            //   message: 'Open User Portal',
            //   child: InkWell(
            //     child: const Icon(Icons.open_in_new_outlined),
            //     onTap: () {
            //       html.window.open(twinnedUrl(), 'new tab');
            //     },
            //   ),
            // ),
            divider,
            divider,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(140, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              onPressed: () {
                _showUserPopup(context, "Add");
              },
              child: Text(
                'Add New User',
                style: UserSession.getLabelTextStyle()
                    .copyWith(color: secondaryColor),
              ),
            ),
            divider,
            SizedBox(
              width: 250,
              height: 30,
              child: SearchBar(
                onChanged: (value) {
                  _searchEntities(value);
                },
                hintText: "Search Users",
              ),
            ),
          ],
        ),
        divider,
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Table(
              border: TableBorder.all(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1),
                // 4: FlexColumnWidth(2),
                5: FlexColumnWidth(1),
              },
              children: rows,
            ),
          ),
        ),
      ],
    );
  }
}

class TableHeader extends StatelessWidget {
  final String title;
  const TableHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          title,
          style: UserSession.getLabelTextStyle()
              .copyWith(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}
