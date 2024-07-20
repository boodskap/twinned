import 'package:eventify/eventify.dart' as event;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;

final TextStyle _titleStyle = GoogleFonts.acme(
    color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold);

final TextStyle _warnTextStyle = GoogleFonts.acme(
    color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold);

final TextStyle _labelPopupTextStyle = GoogleFonts.acme(
    color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);

final TextStyle _errorPopupTextStyle = GoogleFonts.acme(
    color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold);

const hdivider = SizedBox(
  width: 8,
);

const Color primaryColor = Color(0xFF0C244A);
const Color secondaryColor = Color(0xFFFFFFFF);

class TwinnedRolePage extends StatefulWidget {
  const TwinnedRolePage({
    super.key,
  });

  @override
  State<TwinnedRolePage> createState() => _TwinnedRolePageState();
}

class _TwinnedRolePageState extends BaseState<TwinnedRolePage> {
  late Image bannerImage;
  final List<Widget> _cards = [];
  final List<twinned.Role> _entities = [];
  event.Listener? listener;

  @override
  void initState() {
    super.initState();

    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );

    listener = BaseState.layoutEvents.on(PageEvent.teamChanged.name, context,
        (ev, context) {
      setup();
    });
  }

  @override
  void setup() async {
    _loadEntities();
  }

  @override
  void dispose() {
    BaseState.layoutEvents.off(listener);
    super.dispose();
  }

  void _loadEntities() async {
    execute(() async {
      List<Widget> cards = [];
      List<twinned.Role> entities = [];

      var res = await UserSession.twin.listRoles(
        apikey: UserSession().getAuthToken(),
        body: const twinned.ListReq(page: 0, size: 100),
      );

      if (validateResponse(res)) {
        for (twinned.Role r in res.body!.values!) {
          _buildCard(r, cards);
          entities.add(r);
        }
      }

      refresh(sync: () {
        _entities.clear();
        _cards.clear();
        _cards.addAll(cards);
        _entities.addAll(entities);
      });
    });
  }

  void _searchEntities(String search) async {
    if (search.isEmpty) {
      _loadEntities();
      return;
    }

    execute(() async {
      List<Widget> cards = [];
      List<twinned.Role> entities = [];

      var res = await UserSession.twin.searchRoles(
          apikey: UserSession().getAuthToken(),
          body: twinned.SearchReq(search: search, page: 0, size: 10));

      if (validateResponse(res)) {
        for (twinned.Role r in res.body!.values!) {
          _buildCard(r, cards);
          entities.add(r);
        }
      }

      refresh(sync: () {
        _entities.clear();
        _cards.clear();
        _cards.addAll(cards);
        _entities.addAll(entities);
      });
    });
  }

  void _addNewEntity(String roleName, String roleDescription) async {
    busy();
    try {
      twinned.RoleInfo info = twinned.RoleInfo(
        name: roleName,
        description: roleDescription,
      );

      var res = await UserSession.twin
          .createRole(apikey: UserSession().getAuthToken(), body: info);

      if (validateResponse(res)) {
        twinned.Role entity = res.body!.entity!;
        _entities.add(entity);
        _buildCard(entity, _cards);
      }

      refresh();
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }

  void _updateRole(
      String roleId, String roleName, String roleDescription) async {
    busy();
    try {
      twinned.RoleInfo info = twinned.RoleInfo(
        name: roleName,
        description: roleDescription,
      );

      var res = await UserSession.twin.updateRole(
        apikey: UserSession().getAuthToken(),
        roleId: roleId,
        body: info,
      );

      if (validateResponse(res)) {
        twinned.Role updatedRole = res.body!.entity!;
        int index = _entities.indexWhere((element) => element.id == roleId);
        if (index != -1) {
          _entities[index] = updatedRole;
          _updateCards();
        }
      }

      refresh();
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
    }
    busy(busy: false);
  }

  void _updateCards() {
    List<Widget> updatedCards = [];
    for (twinned.Role entity in _entities) {
      _buildCard(entity, updatedCards);
    }
    setState(() {
      _cards.clear();
      _cards.addAll(updatedCards);
    });
  }

  _showRolePopup(BuildContext context, {twinned.Role? role}) {
    String roleName = role?.name ?? '';
    String roleDescription = role?.description ?? '';
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
                  Text(role != null ? 'Update Role' : 'Add Role',
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: roleName,
                    onChanged: (value) {
                      roleName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter valid name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Name',
                      errorStyle: _errorPopupTextStyle,
                      labelStyle: _labelPopupTextStyle,
                    ),
                  ),
                  TextFormField(
                    initialValue: roleDescription,
                    onChanged: (value) {
                      roleDescription = value;
                    },
                    onFieldSubmitted: (value) {
                      if (formKey.currentState!.validate()) {
                        if (role != null) {
                          _updateRole(role.id, roleName,
                              roleDescription); // Update existing role
                        } else {
                          _addNewEntity(
                              roleName, roleDescription); // Add new role
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Description',
                      errorStyle: _errorPopupTextStyle,
                      labelStyle: _labelPopupTextStyle,
                    ),
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
                            if (role != null) {
                              _updateRole(role.id, roleName,
                                  roleDescription); // Update existing role
                            } else {
                              _addNewEntity(
                                  roleName, roleDescription); // Add new role
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          // minimumSize: const Size(140, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        child: Text(
                          role != null ? 'Update' : 'Submit',
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
    // set up the buttons
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
        "Deleting a role can not be undone.\nYou will loose all of the role data, history, etc.\n\nAre you sure you want to delete?",
        style: _warnTextStyle,
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _removeEntity(String id) async {
    busy();
    try {
      int index = _entities.indexWhere((element) => element.id == id);
      var res = await UserSession.twin
          .deleteRole(apikey: UserSession().getAuthToken(), roleId: id);

      if (validateResponse(res)) {
        _entities.removeAt(index);
        _cards.removeAt(index);
      }
      refresh();
    } catch (e, s) {
      debugPrint('e');
      debugPrint('$s');
    }
    busy(busy: false);
  }

  void _buildCard(twinned.Role entity, List<Widget> cards) {
    ImageProvider? image = const AssetImage('images/user.png');

    Widget newCard = Tooltip(
      message: '${entity.name}\n${entity.description}',
      child: InkWell(
        onDoubleTap: () {
          _showRolePopup(context, role: entity); // Pass the role object here
        },
        child: Card(
          color: Colors.transparent,
          elevation: 5,
          child: Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 30,
                  bottom: 30,
                  right: 30,
                  child: Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: image,
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        entity.name,
                        // clippedName,
                        style: _titleStyle.copyWith(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          confirmDeletion(context, entity.id);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    cards.add(newCard);
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
            // divider,
            // divider,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(140, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              onPressed: () {
                _showRolePopup(context);
              },
              child: Text(
                'Add New Role',
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
                hintText: "Search Roles",
              ),
            ),
          ],
        ),
        divider,
        if (_cards.isEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: const Center(child: Text(('No Roles found'))),
          ),
        if (_cards.isNotEmpty)
          Expanded(
            flex: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  itemCount: _cards.length,
                  itemBuilder: (ctx, index) {
                    return _cards[index];
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
