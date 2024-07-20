import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twinned/widgets/commons/left_side_image_page_list_item.dart';
import 'package:twinned/widgets/commons/paragraph.dart';
import 'package:twinned/widgets/digitaltwin_menu_bar.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/widgets/commons/widgets.dart';
import 'package:twinned/widgets/footer.dart';
import 'package:google_fonts/google_fonts.dart';

final TextStyle h2 = GoogleFonts.acme(
  color: loginTextColor,
  fontSize: 20,
);

class ContactPage extends StatelessWidget {
  static const String name = 'contact';

  static const String buildTitle = "Contact Us";

  static const String buildDescription = "Our Office Location";
  static const List<Paragraph> buildParagraphs = [
    Paragraph(text: 'United States'),
    Paragraph(text: 'Boodskap Inc.,'),
    Paragraph(text: '8951 Cypress Waters Blvd, suite 160'),
    Paragraph(text: 'Dallas, TX 75019'),
  ];

  const ContactPage({Key? key}) : super(key: key);

  Widget buildPage(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: <Widget>[
                const NocodeMenuBar(
                  selectedMenu: 'CONTACT US',
                ),
                LeftSideImagePageListItem(
                  imageUrl: "assets/images/contact-bg.png",
                  title: buildTitle,
                  description: buildDescription,
                  paragraphs: buildParagraphs,
                  contentSection: const ContactForm(),
                ),
                divider,
                const Footer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPage(context),
      backgroundColor: bgColor,
    );
  }
}

class ContactForm extends StatefulWidget {
  final Color textColor;

  const ContactForm({super.key, this.textColor = Colors.white});
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String fullName = '';
  String companyName = '';
  String email = '';
  String mobileNumber = '';
  String subject = '';
  String message = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Full Name'),
            TextFormField(
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
              ),
              style: TextStyle(color: widget.textColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
              onSaved: (value) {
                fullName = value!;
              },
            ),
            const SizedBox(height: 5),
            _buildLabel('Company Name'),
            TextFormField(
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your company name';
                }
                return null;
              },
              style: TextStyle(color: widget.textColor),
              onSaved: (value) {
                companyName = value!;
              },
            ),
            const SizedBox(height: 5),
            _buildLabel('Email ID'),
            TextFormField(
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
              ),
              style: TextStyle(color: widget.textColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else if (!RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onSaved: (value) {
                email = value!;
              },
            ),
            const SizedBox(height: 5),
            _buildLabel('Mobile Number'),
            TextFormField(
              maxLength: 10,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                counterText: "",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
              ),
              style: TextStyle(color: widget.textColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your mobile number';
                }
                return null;
              },
              onSaved: (value) {
                mobileNumber = value!;
              },
            ),
            const SizedBox(height: 5),
            _buildLabel('Subject'),
            TextFormField(
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your subject';
                }
                return null;
              },
              style: TextStyle(color: widget.textColor),
              onSaved: (value) {
                subject = value!;
              },
            ),
            const SizedBox(height: 5),
            _buildLabel('Message'),
            TextFormField(
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.textColor),
                ),
              ),
              style: TextStyle(color: widget.textColor),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
              onSaved: (value) {
                message = value!;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(140, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
              },
              child: Text(
                'Send',
                style: h2.copyWith(color: widget.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: widget.textColor),
    );
  }
}
