import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/offer/screen/offer_screen.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OfferSection {
  OfferSection._();

  static const double buttonHeight = 37;

  static const double collapsedHeight = buttonHeight + Dimensions.paddingMedium;
}

class OfferGrid extends StatelessWidget {
  const OfferGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_QuickActionButtonWidget> items = _offerItems(context, pined: false);
    return Container(
      color: context.surfaceContainer,
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: Dimensions.paddingDefault),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Column(children: [
              Row(children: [
                Expanded(child: items[0]),
                const SizedBox(width: Dimensions.paddingSmall),
                Expanded(child: items[1]),
              ]),
              const SizedBox(height: Dimensions.paddingSmall),

              Row(children: [
                Expanded(child: items[2]),
                const SizedBox(width: Dimensions.paddingSmall),
                Expanded(child: items[3]),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class PinnedOfferBar extends StatelessWidget {
  final bool showShadow;
  const PinnedOfferBar({super.key, this.showShadow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        border: showShadow ? Border(bottom: BorderSide(color: context.outline, width: 1)) : null,
      ),
      child: const _OfferBar(),
    );
  }
}

class _OfferBar extends StatelessWidget {
  const _OfferBar();

  @override
  Widget build(BuildContext context) {
    final List<_QuickActionButtonWidget> items = _offerItems(context, pined: true);
    return Container(
      color: context.surfaceContainer,
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: Dimensions.paddingLarge, right: Dimensions.paddingLarge, bottom: Dimensions.paddingMedium),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSmall),
          itemBuilder: (context, index) => items[index],
        ),
      ),
    );
  }
}

List<_QuickActionButtonWidget> _offerItems(BuildContext context, {bool pined = true}) => [
  _QuickActionButtonWidget(
    label: pined ? 'offers'.tr : 'grab_offers'.tr,
    icon: Icons.local_offer_outlined,
    imageIcon: Images.offerIcon2,
    iconColor: context.bgInfoDefault,
    backgroundColor: context.bgInfoMedium,
    isPined: pined,
    onTap: () => Get.toNamed(RouteHelper.getOfferRoute(), arguments: OfferScreen(title: 'offers'.tr, iconPath: Images.offerIcon)),
  ),
  _QuickActionButtonWidget(
    label: pined ? 'nearby'.tr : 'find_nearby'.tr,
    icon: Icons.near_me_outlined,
    imageIcon: Images.findNearbyIcon,
    iconColor: context.bgWarningDefault,
    backgroundColor: context.bgWarningMedium,
    isPined: pined,
    onTap: () => Get.toNamed(RouteHelper.getMapViewRoute()),
  ),
  _QuickActionButtonWidget(
    label: 'top_rated'.tr,
    icon: Icons.workspace_premium_outlined,
    imageIcon: Images.topRatedIcon,
    iconColor: context.bgSuccessDefault,
    backgroundColor: context.bgSuccessMedium,
    isPined: pined,
    onTap: () => Get.toNamed(RouteHelper.getOfferRoute(), arguments: OfferScreen(title: 'top_rated'.tr, iconPath: Images.topRatedIcons, isTopRated: true)),
  ),
  _QuickActionButtonWidget(
    label: 'free_delivery'.tr,
    icon: Icons.delivery_dining_outlined,
    imageIcon: Images.freeDeliveryIcon,
    iconColor: context.bgInfoDefault,
    backgroundColor: context.bgInfoMedium,
    isPined: pined,
    onTap: () => Get.toNamed(RouteHelper.getOfferRoute(), arguments: OfferScreen(title: 'free_delivery'.tr, iconPath: Images.freeDeliveryIcons, isFreeDelivery: true)),
  ),
];

class _QuickActionButtonWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final bool isPined;
  final String? imageIcon;

  const _QuickActionButtonWidget({
    required this.label, required this.icon, required this.iconColor, required this.backgroundColor, required this.onTap,
    this.isPined = false, this.imageIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Widget labelWidget = Text(
      label,
      maxLines: 1, overflow: TextOverflow.ellipsis,
      style: context.subHeading.small.overrideWith(
        color: context.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );

    return CustomInkWellWidget(
      onTap: onTap,
      radius: Dimensions.radiusDefault,
      child: isPined ? Container(
        height: OfferSection.buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
        decoration: BoxDecoration(
          border: Border.all(color: context.outline),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [

          labelWidget,
          const SizedBox(width: Dimensions.padding2xSmall),

          if(imageIcon != null)
            CustomAssetImageWidget(imageIcon!, height: 16, width: 16)
          else
            Icon(icon, color: iconColor, size: 16),
        ]),
      ) : Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingDefault),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Row(children: [
          if(imageIcon != null)
            CustomAssetImageWidget(imageIcon!, height: 16, width: 16)
          else
            Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: Dimensions.paddingSmall),

          Expanded(child: labelWidget),
          const SizedBox(width: Dimensions.padding2xSmall),

          Icon(Get.find<LocalizationController>().isLtr ? Icons.arrow_forward_ios_sharp : Icons.arrow_back_ios, color: iconColor, size: 14),
        ]),
      ),
    );
  }
}
