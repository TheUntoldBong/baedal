import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class OverFlowContainerWidget extends StatelessWidget {
  final String image;
  const OverFlowContainerWidget({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      height: 30, width: 30,
      decoration:  BoxDecoration(
        color: context.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CustomImageWidget(
          image: image,
          fit: BoxFit.cover, height: 30, width: 30,
        ),
      ),
    );
  }
}
