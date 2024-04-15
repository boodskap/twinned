import 'package:flutter/material.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:twinned/widgets/commons/image_wrapper.dart';
import 'package:twinned/widgets/commons/left_side_image_page_list_item.dart';
import 'package:twinned/widgets/commons/paragraph.dart';

class RightSideImagePageListItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  late final List<Paragraph> paragraphs;
  late final String? nextPage;
  bool top;

  RightSideImagePageListItem({
    Key? key,
    this.top = false,
    required this.title,
    required this.imageUrl,
    required this.description,
    this.nextPage,
    this.paragraphs = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (top) {
      return LeftSideImagePageListItem(
        top: top,
        title: title,
        imageUrl: imageUrl,
        description: description,
        nextPage: nextPage,
        paragraphs: paragraphs,
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
                    ...paragraphs,
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
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 100,
                child: ImageWrapper(
                  image: imageUrl,
                ),
              ),
            ],
          )
        ],
      );
    }
  }
}
