import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/features/auth/controllers/restaurant_registration_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BaseCardWidget extends StatelessWidget {
  final RestaurantRegistrationController restaurantRegistrationController;
  final String title;
  final String? description;
  final int index;
  final Function onTap;
  const BaseCardWidget({super.key, required this.restaurantRegistrationController, required this.title, required this.index, required this.onTap, this.description});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return InkWell(
      onTap: onTap as void Function()?,
      child: Stack(clipBehavior: Clip.none, children: [

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
            color: restaurantRegistrationController.businessIndex == index ? context.primary.withValues(alpha: 0.05) : context.surfaceContainer,
            border: restaurantRegistrationController.businessIndex == index && isDesktop ? Border.all(color: context.primary) : !isDesktop ? Border.all(color: restaurantRegistrationController.businessIndex == index ? context.primary
                : context.outlineVariant, width: 0.5) : null,
            boxShadow: restaurantRegistrationController.businessIndex == index ? null : [BoxShadow(color: context.shadow, offset: const Offset(5, 5), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingLarge),
          child: Column(crossAxisAlignment : isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [

            Align(
              alignment: isDesktop ? Alignment.centerLeft : Alignment.center,
              child: Text(title, style: context.subHeading.defaultSize.overrideWith(
                color: restaurantRegistrationController.businessIndex == index ? context.primary : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                fontWeight: restaurantRegistrationController.businessIndex == index ? FontWeight.w600 : isDesktop ? FontWeight.w600 : FontWeight.w400,
              )),
            ),

            SizedBox(height: isDesktop ? Dimensions.paddingSmall : 0),

            isDesktop ? Text(
              description ?? '', style: context.body.small.regular.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
              textAlign: TextAlign.justify, textScaler: const TextScaler.linear(1.1),
            ) : const SizedBox(),

          ]),
        ),

        restaurantRegistrationController.businessIndex == index ? Positioned(
          top: -10, right: -10,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: context.primary,
            ),
            child: Icon(Icons.check, size: 14, color: context.surfaceContainer),
          ),

        ) : const SizedBox()
      ]),
    );
  }
}