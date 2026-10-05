import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:get/get.dart';

class GuestCustomStepper extends StatelessWidget {
  final bool isActive;
  final bool isComplete;
  final bool haveTopBar;
  final String? title;
  final String? subTitle;
  final Widget? child;
  final double height;
  final String? statusImage;
  final Widget? trailing;
  const GuestCustomStepper({super.key,
    required this.title, required this.isActive,
    this.child, this.haveTopBar = true, this.height = 30,
    this.statusImage = Images.orders, this.subTitle,
    required this.isComplete, this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      if(haveTopBar) Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 35),
            height: height,
            child: CustomPaint(
              size: const Size(2, double.infinity),
              painter: DashedLineVerticalPainter(isActive: isComplete),
            ),
          ),

          child == null ? const SizedBox() : child!,
        ],
      ),



      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(7),
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: context.primary.withValues(alpha: 0.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
            child: CustomAssetImageWidget(
              statusImage!, width: 30,
              color: context.primary.withValues(alpha: isComplete ? 1 : 0.5),
            ),
          ),
        ),
        title: Text(title!, style: isComplete ? context.subHeading.defaultSize.medium.overrideWith(
          color: context.primary,
        ) : context.subHeading.defaultSize.regular.overrideWith(
          color: context.textBaseMedium,
        )),
        subtitle: subTitle != null ? Text(subTitle!, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)) : const SizedBox(),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          ?trailing,
          if(trailing != null) const SizedBox(width: Dimensions.paddingSmall),

          if(isActive) Icon(Icons.check_circle, color: context.primary, size:  25),
        ]),
      ),

    ]);
  }
}


class DashedLineVerticalPainter extends CustomPainter {
  final bool? isActive;
  DashedLineVerticalPainter({this.isActive = false});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 6, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = isActive! ?  Theme.of(Get.context!).primaryColor : Get.context!.outline
      ..strokeWidth = size.width;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
