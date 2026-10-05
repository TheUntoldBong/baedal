import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';


class PaymentButtonNew extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final Function onTap;
  const PaymentButtonNew({super.key, required this.isSelected, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            border: Border.all(color: isSelected ? context.primary : context.outlineVariant),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSmall),
          child: Row(children: [
            CustomAssetImageWidget(icon, width: 20, height: 20),
            const SizedBox(width: Dimensions.paddingSmall),

            Expanded(
              child: Text(
                title,
                style: context.subHeading.small.medium,
              ),
            ),

            isSelected ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primary,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ) : const SizedBox(),
          ]),

        ),
      ),
    );
  }
}
