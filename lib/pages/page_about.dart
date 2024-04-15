import 'package:flutter/material.dart';
import '../widgets/commons/left_side_image_page_list_item.dart';
import '../widgets/commons/paragraph.dart';
import '../widgets/digitaltwin_menu_bar.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:twinned/widgets/commons/widgets.dart';
import 'package:twinned/widgets/footer.dart';


class AboutPage extends StatelessWidget {
  static const String name = 'about';
  static const String buildTitle = "About";
  static const String buildDescription = "";
  static const List<Paragraph> buildParagraphs = [];

  const AboutPage({Key? key}) : super(key: key);

  Widget buildPage(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: <Widget>[
                const NocodeMenuBar(
                  selectedMenu: 'ABOUT',
                ),
                LeftSideImagePageListItem(
                  imageUrl: "assets/images/about-bg.png",
                  title: buildTitle,
                  description: buildDescription,
                  paragraphs: buildParagraphs,
                  contentSection: const AboutContentSection(),
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

final List<String> aboutHighlightedText1 = [
  'Gain Real-Time Insights: ',
  'Predictive Performance: ',
  'Remote Empowerment: ',
  'Efficiency Unleashed: ',
  'Tailored Solutions: ',
];

final List<String> aboutsubText1 = [
  'Our digital twin technology delivers dynamic insights, providing a real-time 360-degree view of your assets and processes. This enables you to respond quickly to changes and proactively manage your operations.',
  'Our technology uses predictive analytics to elevate your maintenance strategy. With our digital twin, you can identify potential issues before they arise and schedule maintenance accordingly to ensure uninterrupted operations.',
  'Our technology empowers you to monitor and control your systems remotely, providing the flexibility and agility needed to adapt to a rapidly changing business environment.',
  'Our digital twin serves as a virtual playground, allowing you to test scenarios, identify bottlenecks, and unlock unprecedented levels of efficiency.',
  'Our digital twinning technology is customizable to fit your specific industry requirements. We work closely with you to ensure a seamless integration that maximizes results.',
];

final List<String> aboutHighlightedText2 = [
  'Innovation at the Core: ',
  'Proven Results: ',
  'Customer-Centric Approach: ',
];

final List<String> aboutsubText2 = [
  'Stay ahead of the curve with a partner committed to continuous innovation in digital twinning technology.',
  'Our technology has a track record of delivering tangible results – from increased productivity to reduced operational costs.',
  'Your success is our priority. We work closely with you to understand your goals and tailor our digital twinning technology to meet your specific needs.',
];



class AboutContentSection extends StatelessWidget {
  const AboutContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextCustomize(
            text: "Who we are and What we do?",
            textstyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white)),
        const SizedBox(height: 5),
        const TextCustomize(
            text:
                "Boodskap is a company located in Dallas, TX that specializes in offering an Internet of Things (IoT) Platform. Its primary goal is to help businesses establish connectivity among their hardware devices swiftly and develop connected applications cost-effectively. It is a complete solution for IIoT that combines the MQTT data-transfer protocol with the data acquisition and development capabilities of the Boodskap IoT platform. With Boodskap, you can enhance connectivity, collect more data for advanced analytics, and optimize production. The platform's modular design allows for customization to meet your specific requirements. It is accessible through any device and has a hassle-free licensing model. Its core is focused on providing everything you need, and nothing you don't.",
            textstyle: TextStyle(color: Colors.white, fontSize: 13)),
        const SizedBox(height: 15),
        const TextCustomize(
            text:
                "Increase Your Potential with Our Cutting-Edge Digital Twinning Technology",
            textstyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white)),
        const SizedBox(height: 5),
        const TextCustomize(
            text:
                "In modern industries, innovation is the key to unlocking untapped potential. Our state-of-the-art Digital Twinning Technology is designed to revolutionize the way you operate, by providing a dynamic platform to enhance efficiency, optimize processes, and make informed decisions.",
            textstyle: TextStyle(color: Colors.white, fontSize: 13)),
        const SizedBox(height: 15),
        const TextCustomize(
            text: "Why Choose Our Digital Twinning Technology??",
            textstyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white)),
        const SizedBox(height: 5),
        UnorderedListWidget(
            highlightedDynamicText: aboutHighlightedText1,
            subDynamicText: aboutsubText1),
        const TextCustomize(
            text: "Why Partner With Us?",
            textstyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white)),
        const SizedBox(height: 5),
        UnorderedListWidget(
            highlightedDynamicText: aboutHighlightedText2,
            subDynamicText: aboutsubText2),
        const TextCustomize(
            text:
                "Experience the Future with Our Digital Twinning Technology: Exponent Your Potential Today.",
            textstyle: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontStyle: FontStyle.italic)),
        const SizedBox(height: 5),
         const TextCustomize(
            text: "Connect with us to schedule a personalized consultation and discover how our technology can propel your business to new heights.",
            textstyle: TextStyle(
                fontSize: 13,
                color: Colors.white)),
       
      ],
    );
  }
}

class UnorderedListWidget extends StatelessWidget {
  final List<String> highlightedDynamicText;
  final List<String> subDynamicText;
  const UnorderedListWidget({
    super.key,
    required this.highlightedDynamicText,
    required this.subDynamicText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < highlightedDynamicText.length; index++)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 30, right: 0),
            leading: const Icon(Icons.circle, size: 10, color: Colors.white),
            title: RichText(
              text: TextSpan(
                style:
                    const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                children: [
                  TextSpan(
                    text: highlightedDynamicText[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: subDynamicText[index],
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }
}

class TextCustomize extends StatelessWidget {
  final String text;
  final TextStyle textstyle;
  const TextCustomize(
      {super.key,
      required this.text,
      this.textstyle = const TextStyle(fontSize: 13, color: Colors.white)});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: textstyle);
  }
}
