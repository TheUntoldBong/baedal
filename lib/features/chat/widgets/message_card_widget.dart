import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class MessageCardWidget extends StatelessWidget {
  final String userTypeImage;
  final String userType;
  final String message;
  final String time;
  final Function()? onTap;
  final bool isUnread;
  final int count;
  const MessageCardWidget({super.key, required this.userTypeImage, required this.userType, required this.message, required this.time,
    this.onTap, this.isUnread = false, required this.count});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      isBorder: false,
      padding: const EdgeInsets.all(Dimensions.paddingSmall),
      child: InkWell(
        onTap: onTap,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          ClipOval(
            child: CustomImageWidget(height: 50, width: 50, image: userTypeImage,
          )),
          const SizedBox(width: Dimensions.paddingSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Flexible(
                child: Row(
                  children: [
                    Flexible(child: Text(userType, style: context.subHeading.defaultSize.medium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: Dimensions.padding2xSmall),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall, vertical: Dimensions.padding2xSmall),
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      ),
                      child: Text(
                        'admin'.tr, style: context.subHeading.small.medium.overrideWith(color: context.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.padding2xSmall),

              Align(
                alignment: Alignment.centerRight,
                child: Text(time, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
              ),
            ]),
            const SizedBox(height: Dimensions.padding2xSmall),

            Text(
              message, style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Dimensions.padding2xSmall),

            Align(
              alignment: Alignment.centerRight,
              child: count > 0 ? Container(
                padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                decoration: BoxDecoration(
                  color: context.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(count.toString(), style: context.subHeading.extraSmall.regular.overrideWith(color: context.surfaceContainer)),
              ) : const SizedBox(height: 15),
            ),

          ])),
        ]),
      ),
    );
  }
}
