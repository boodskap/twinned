
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef AddMenuGroup = void Function(bool cleared);

class MenuGroupAdd extends StatefulWidget {
  // DashboardMenuGroup menuGroup;
  final AddMenuGroup addMenuGroup;

  const MenuGroupAdd({
    super.key,
    // required this.menuGroup,
    required this.addMenuGroup,
  });

  @override
  State<MenuGroupAdd> createState() => _MenuGroupAddState();
}

class _MenuGroupAddState extends State<MenuGroupAdd> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<String> devName = ["Web", "Tablet", "Mobile"];
  List<bool> responseList = List.generate(3, (index) => true);
  double _idheight = 30;

  final TextEditingController _menuGroupName = TextEditingController();
  final TextEditingController _menuGroupDescription = TextEditingController();
  final TextEditingController _menuGroupOrder = TextEditingController();
  final TextEditingController _menuGroupIcon = TextEditingController();

  bool _webSupported = true;
  bool _tabSupported = true;
  bool _mobSupported = true;

  Uint8List? _iconBytes;

  void _uploadIcon() async {
    try {
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'JPEG', 'JPG', 'PNG'],
      );

      if (result != null) {
        var mgF = result.files.first;
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
        setState(() {
          _iconBytes = mgF.bytes;
        });
      } else {
        debugPrint('Image not selected');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.all(5),
        height: 90,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                RichText(
                  text: const TextSpan(
                    text: 'Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: _idheight,
                  width: 250,
                  child: TextFormField(
                    controller: _menuGroupName,
                    keyboardType: TextInputType.text,
                    cursorHeight: 17,
                    maxLength: 40,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        top: 5,
                      ),
                      errorStyle: TextStyle(height: 0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          _idheight = 50;
                        });
                        return 'Name Required';
                      } else {
                        setState(() {
                          _idheight = 30;
                        });
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                RichText(
                  text: const TextSpan(
                    text: 'Description',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 30,
                  width: 250,
                  child: TextFormField(
                    controller: _menuGroupDescription,
                    keyboardType: TextInputType.text,
                    cursorHeight: 17,
                    maxLength: 40,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        top: 5,
                      ),
                      errorStyle: TextStyle(height: 0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                RichText(
                  text: const TextSpan(
                    text: 'Order',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 30,
                  width: 50,
                  child: TextFormField(
                    controller: _menuGroupOrder,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    cursorHeight: 17,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        top: 5,
                      ),
                      errorStyle: TextStyle(height: 0),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                RichText(
                  text: const TextSpan(
                    text: 'Icon',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Tooltip(
                  preferBelow: false,
                  message: 'Upload Menugroup Icon',
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child: InkWell(
                        onTap: _uploadIcon,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _iconBytes == null
                              ? Image.asset(
                                  'assets/images/upload_icon.png',
                                  fit: BoxFit.fill,
                                )
                              : Image.memory(
                                  _iconBytes!,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      )),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 250,
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: responseList.length,
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IgnorePointer(
                        ignoring: false,
                        child: Transform.scale(
                          scale: 0.7,
                          child: Checkbox(
                            value: responseList[index],
                            onChanged: (value) {
                              setState(() {
                                responseList[index] = value ?? false;
                                switch (index) {
                                  case 0:
                                    _webSupported = value ?? false;
                                    break;
                                  case 1:
                                    _tabSupported = value ?? false;
                                    break;
                                  case 2:
                                    _mobSupported = value ?? false;
                                    break;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Text(devName[index]),
                    ],
                  );
                },
              ),
            ),
            InkWell(
              onTap: () {
                final map = {
                  "displayName": _menuGroupName.text,
                  "description": _menuGroupDescription.text,
                  "icon": "string",
                  "order": _menuGroupOrder.text.isNotEmpty
                      ? int.parse(_menuGroupOrder.text)
                      : -1,
                  "webSupported": _webSupported,
                  "tabletSupported": _tabSupported,
                  "mobileSupported": _mobSupported
                };

                print('create => $map');
              },
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                  color: Colors.green,
                ),
                height: 30,
                width: 150,
                child: const Center(
                  child: Text(
                    'Create Menugroup',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
