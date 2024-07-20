import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned/core/user_session.dart';
import 'package:twinned/widgets/commons/label_textfield.dart';

class TwinnedProfilePage extends StatefulWidget {
  const TwinnedProfilePage({super.key});

  @override
  State<TwinnedProfilePage> createState() => _TwinnedProfilePageState();
}

class _TwinnedProfilePageState extends BaseState<TwinnedProfilePage> {
  late Image bannerImage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _webController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();

    String asset = 'assets/images/ldashboard_banner.png';
    bannerImage = Image.asset(
      asset,
      fit: BoxFit.fill,
    );
  }

  @override
  void setup() {}

  @override
  Widget build(BuildContext context) {
    const vdivider = SizedBox(
      height: 8,
    );
    const hdivider = SizedBox(
      width: 8,
    );
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: bannerImage,
            ),
            vdivider,
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(140, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: UserSession.getLabelTextStyle()
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    hdivider,
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(140, 40),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: UserSession.getLabelTextStyle()
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    hdivider,
                  ],
                ),
                vdivider,
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Row(
                    children: [
                      hdivider,
                      Expanded(
                        child: LabelTextField(
                          readOnlyVal: true,
                          label: "Email",
                          controller: _emailController,
                        ),
                      ),
                      hdivider,
                      Expanded(
                        child: LabelTextField(
                          label: 'Name',
                          controller: _nameController,
                        ),
                      ),
                      hdivider,
                    ],
                  ),
                ),
                vdivider,
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Row(
                    children: [
                      hdivider,
                      Expanded(
                        child: LabelTextField(
                          label: 'Address',
                          controller: _addressController,
                        ),
                      ),
                      hdivider,
                      Expanded(
                        child: LabelTextField(
                          label: 'Phone',
                          controller: _phoneController,
                        ),
                      ),
                      hdivider,
                    ],
                  ),
                ),
                vdivider,
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Row(
                    children: [
                      hdivider,
                      Expanded(
                        child: LabelTextField(
                          label: 'Website',
                          controller: _webController,
                        ),
                      ),
                      hdivider,
                      Expanded(
                        child: LabelTextField(
                          label: 'Description',
                          controller: _descController,
                        ),
                      ),
                      hdivider
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
