import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class HomeHeaderWidget extends StatefulWidget {
  const HomeHeaderWidget({super.key});

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return Container(
      width: Dimensions.webMaxWidth,
      color: context.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingLarge,
        vertical: Dimensions.paddingSmall,
      ),
      child: Row(
        children: [
          // Elegant Brand Logo Badge
          Container(
            height: 42,
            width: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: context.outline.withValues(alpha: 0.35), width: 1),
            ),
            child: Center(
              child: CustomAssetImageWidget(Images.logo, height: 32, width: 32, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          // Deliver To Location Pill
          Expanded(
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: Get.context!,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (con) => const AddressBottomSheet(),
                ).then((value) {
                  Get.find<DashboardController>().hideSuggestedLocation();
                  if (mounted) setState(() {});
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: GetBuilder<LocationController>(builder: (locationController) {
                  String address = AddressHelper.getAddressFromSharedPref()?.address ?? 'not_set_yet'.tr;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deliver To Row with Live Indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'deliver_to'.tr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Location text with pin & animated chevron
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 15, color: primary),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              address,
                              style: context.heading.small.overrideWith(
                                color: context.textBaseDefault,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: primary),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          // Favourites Action Button
          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getFavouriteScreen()),
            borderRadius: BorderRadius.circular(21),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.outline.withValues(alpha: 0.35), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: CustomAssetImageWidget(
                Images.navFavourite,
                height: 20,
                width: 20,
                fit: BoxFit.contain,
                color: context.textBaseDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
