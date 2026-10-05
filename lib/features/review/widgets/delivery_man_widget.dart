import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DeliveryManWidget extends StatelessWidget {
  final DeliveryMan? deliveryMan;
  const DeliveryManWidget({super.key, required this.deliveryMan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingDefault),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text('delivery_man'.tr, style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
        const SizedBox(height: Dimensions.paddingMedium),

        Row(children: [

          ClipOval(child: CustomImageWidget(
            image: '${deliveryMan!.imageFullUrl}',
            height: 48, width: 48, fit: BoxFit.cover,
          )),
          const SizedBox(width: Dimensions.paddingMedium),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              '${deliveryMan!.fName} ${deliveryMan!.lName}',
              style: context.heading.defaultSize.medium,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Dimensions.padding2xSmall),

            RatingBarWidget(rating: deliveryMan!.avgRating, size: 15, ratingCount: deliveryMan!.ratingCount ?? 0),

          ])),

        ]),

      ]),
    );
  }
}
