import 'package:flutter/material.dart';
import 'package:twinned/core/constants.dart';
import 'package:twinned/widgets/commons/image_wrapper.dart';
import 'package:twinned/widgets/commons/paragraph.dart';

class LeftSideImagePageListItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  late final String? nextPage;
  late final List<Paragraph>? paragraphs;
  final Widget contentSection;
  bool top;

  LeftSideImagePageListItem(
      {Key? key,
      this.top = false,
      required this.title,
      required this.imageUrl,
      required this.description,
      this.nextPage,
      this.paragraphs = const [],
      this.contentSection = const Text("")})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (top) {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ImageWrapper(
                image: imageUrl,
              ),
              Container(
                margin: marginBottom12,
                child: Text(
                  title,
                  style: getHeadlineTextStyle(context),
                ),
              ),
              Container(
                margin: marginBottom8,
                child: Text(
                  description,
                  style: getBodyTextStyle(context),
                ),
              ),
              ...paragraphs!,
              contentSection,
              if (null != nextPage)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: marginBottom24,
                    // child: ReadMoreButton(
                    //   onPressed: () => Navigator.pushNamed(context, nextPage!),
                    // ),
                  ),
                ),
            ],
          )
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 100,
                child: ImageWrapper(
                  image: imageUrl,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 100,
                child: Column(
                  children: [
                    Container(
                      margin: marginBottom12,
                      child: Text(
                        title,
                        style: getHeadlineTextStyle(context),
                      ),
                    ),
                    Container(
                      margin: marginBottom8,
                      child: Text(
                        description,
                        style: getBodyTextStyle(context),
                      ),
                    ),
                    ...paragraphs!,
                    contentSection,
                    if (null != nextPage)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          margin: marginBottom24,
                          // child: ReadMoreButton(
                          //   onPressed: () =>
                          //       Navigator.pushNamed(context, nextPage!),
                          // ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          )
        ],
      );
    }
  }
}
