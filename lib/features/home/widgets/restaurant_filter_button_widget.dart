import 'package:stackfood_multivendor/features/home/widgets/home_offer_section_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';


class RestaurantsFilterButtonWidget extends StatelessWidget {
  const RestaurantsFilterButtonWidget({super.key, required this.isSelected, this.onTap, required this.buttonText});

  final bool isSelected;
  final void Function()? onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        child: Container(
          height: OfferSection.buttonHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
          decoration: BoxDecoration(
            color: isSelected ? context.primary : context.surfaceContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(
              color: isSelected ? context.primary : context.outline,
            ),
          ),
          child: Text(buttonText, style: context.subHeading.defaultSize.semiBold.copyWith(
            color: isSelected ? context.surfaceContainer : Theme.of(context).textTheme.bodyLarge!.color,
          )),
        ),
      ),
    );
  }
}
