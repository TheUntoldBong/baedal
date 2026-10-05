import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BogoOfferItemCard extends StatelessWidget {
  final BogoOfferCardModel offer;
  const BogoOfferItemCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.getBogoOfferDetailsRoute((offer.slug != null && offer.slug!.isNotEmpty) ? offer.slug! : '${offer.id}')),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingOverSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(image: offer.imageFullUrl ?? '', height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: Dimensions.paddingSmall),
        
            Text(offer.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.heading.large.strong),
            const SizedBox(height: Dimensions.padding2xSmall),
        
            if(offer.offerLabel != null && offer.offerLabel!.isNotEmpty) ...[
              Text(offer.offerLabel!, style: context.subHeading.small.regular.overrideWith(color: context.textInfosMedium)),
              const SizedBox(height: Dimensions.padding2xSmall),
            ],
        
            Text(offer.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.subHeading.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
          ],
        ),
      ),
    );
  }
}
