import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class NotificationBottomSheet extends StatelessWidget {
  final NotificationModel notificationModel;
  const NotificationBottomSheet({super.key, required this.notificationModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const SizedBox(),

          Container(
            height: 5, width: 35,
            decoration: BoxDecoration(
              color: context.bgNeutralLight,
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingDefault),
            child: InkWell(
              onTap: () => Get.back(),
              child: Icon(Icons.close, color: context.iconDisabledDefault, size: 25),
            ),
          ),
        ]),

        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge, vertical: Dimensions.paddingDefault),
              child: Column(children: [

                notificationModel.imageFullUrl != null && notificationModel.imageFullUrl!.isNotEmpty ? ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                  child: CustomImageWidget(
                    placeholder: Images.placeholderPng,
                    image: '${notificationModel.imageFullUrl}',
                    height: 140, width: MediaQuery.of(context).size.width, fit: BoxFit.cover,
                  ),
                ) : const SizedBox(),
                SizedBox(height: notificationModel.imageFullUrl != null && notificationModel.imageFullUrl!.isNotEmpty ? Dimensions.paddingDefault : 0),

                Text(notificationModel.data!.title ?? '', style: context.heading.large.strong, textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.padding2xSmall),

                Text(notificationModel.data!.description ?? '', style: context.body.small.regular, textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.paddingSmall),

              ]),
            ),
          ),
        ),

      ]),

    );
  }
}
