import 'dart:typed_data';

import 'package:flutter/material.dart';

class MenuItems extends StatefulWidget {
  const MenuItems({super.key});

  @override
  _MenuItemsState createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems>
 {

  final List<bool> _showContainerList = [true];
  List<String> factoryList = [''];
  List<String> locationList = [''];
  List<String> descriptionList = [''];
  String selectedCategory = '';
  static List<Map<String, dynamic>> mainUnitList = [];
  Uint8List? _iconBytes;

  void _addNew(int index, String fac, String loc, String desc) {
    setState(() {
      if (index == _showContainerList.length - 1) {
        _showContainerList.add(true);
        factoryList.add('');
        locationList.add('');
        descriptionList.add('');
        // FactoryProperties.mainFacList
        // .add({'fname': fac, 'desc': desc, 'loca': loc});
      } else {
        var linked = mainUnitList
            .where((map) => map['fname'] == fac && map['loca'] == loc)
            .toList()
            .length;

        if (linked > 0) {
          // Mypopup.showPopUpMessage(context);
        } else {
          _showContainerList.removeAt(index);
          factoryList.removeAt(index);
          locationList.removeAt(index);
          descriptionList.removeAt(index);
        }
      }
    });
  }

  void _uploadIcon() async {
    try {
      // FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
      //   allowMultiple: false,
      //   type: FileType.custom,
      //   allowedExtensions: ['jpg', 'png', 'jpeg', 'JPEG', 'JPG', 'PNG'],
      // );

      // if (result != null) {
      //   var mgF = result.files.first;
      // var res = await ImageHelper.uploadMenuGroupIcon(
      //   file: mgF.bytes!.toList(),
      //   fileName: mgF.name,
      //   menuGroupId: widget.menuGroup.id,
      // );

      // if (!res.ok) {
      //   // alert('Error', res.msg ?? 'Unknown error');
      //   return;
      // }

      // setState(() {
      //   String id = res.entity!.id;
      //   _menuGroupIcon.text = id;
      // });
      // setState(() {
      //   _iconBytes = mgF.bytes;
      // });
      // } else {
      //   debugPrint('Image not selected');
      // }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      width: 600,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
          border: Border.all(color: Colors.grey)),
      child: ListView(children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < _showContainerList.length; i++)
                GestureDetector(
                  child: Column(
                    children: [
                      Container(
                          // color: Colors.amber,
                          height: 135,
                          // width: 600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 450,
                                    // color: Colors.amber,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Name'),
                                              // FactoryCreation().InputField()
                                              Container(
                                                width: 210,
                                                // padding: EdgeInsets.all(6),
                                                height: 35,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.rectangle,
                                                  border: Border.all(
                                                    color: Colors.grey.shade400,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: factoryList[i]),
                                                  onChanged: (value) {
                                                    factoryList[i] = value;
                                                  },
                                                  cursorColor: Colors.grey,
                                                  cursorHeight: 17,
                                                  textAlign: TextAlign.start,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 10,
                                                            bottom: 12),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Type'),
                                              // FactoryCreation().InputField()
                                              Container(
                                                width: 210,
                                                // padding: EdgeInsets.all(6),
                                                height: 35,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.rectangle,
                                                  border: Border.all(
                                                    color: Colors.grey.shade400,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text:
                                                              locationList[i]),
                                                  onChanged: (value) {
                                                    locationList[i] = value;
                                                  },
                                                  cursorColor: Colors.grey,
                                                  cursorHeight: 17,
                                                  textAlign: TextAlign.start,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 10,
                                                            bottom: 12),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(top: 5),
                                        width: 450,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Roles'),
                                                  // FactoryCreation().InputField()
                                                  Container(
                                                    width: 210,
                                                    // padding: EdgeInsets.all(6),
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.rectangle,
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade400,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: TextField(
                                                      controller:
                                                          TextEditingController(
                                                              text:
                                                                  descriptionList[
                                                                      i]),
                                                      onChanged: (value) {
                                                        descriptionList[i] =
                                                            value;
                                                      },
                                                      cursorColor: Colors.grey,
                                                      cursorHeight: 17,
                                                      textAlign:
                                                          TextAlign.start,
                                                      decoration:
                                                          const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                bottom: 12),
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 210,
                                                // color: Colors.amber,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Icon'),
                                                    Tooltip(
                                                      preferBelow: false,
                                                      message:
                                                          'Upload Menugroup Icon',
                                                      child: SizedBox(
                                                          height: 30,
                                                          width: 30,
                                                          child: InkWell(
                                                            onTap: _uploadIcon,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              child: _iconBytes ==
                                                                      null
                                                                  ? Image.asset(
                                                                      'assets/images/add_record.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image.memory(
                                                                      _iconBytes!,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                            ),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 30, left: 20),
                                    child: InkWell(
                                      onTap: () {
                                        // var findLen =
                                        //     mainFacList
                                        //     .where((map) =>
                                        //         map['fname'] ==
                                        //             factoryList[i] &&
                                        //         map['loca'] == locationList[i])
                                        //     .toList();

                                        // if (9 > 0 &&
                                        //     i ==
                                        //         _showContainerList.length - 1) {
                                        // Mypopup.showPopUpMessage(context);

                                        _addNew(
                                            i,
                                            factoryList[i],
                                            locationList[i],
                                            descriptionList[i]);
                                      },
                                      child: Image.asset(
                                          (i == _showContainerList.length - 1)
                                              ? 'assets/images/add_record.png'
                                              : 'assets/images/close.png'),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Container(
                          height: 1,
                          // margin: EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
                              color: (i == _showContainerList.length - 1
                                  ? Colors.transparent
                                  : Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ),

              // Text()
            ],
          ),
        ),
      ]),
    );
  }
}
