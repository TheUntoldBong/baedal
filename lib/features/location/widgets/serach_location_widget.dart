import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/features/location/widgets/location_search_dialog.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class SearchLocationWidget extends StatelessWidget {
  final GoogleMapController? mapController;
  final String? pickedAddress;
  final bool? isEnabled;
  final bool? isPickedUp;
  final bool? fromDialog;
  final String? hint;
  const SearchLocationWidget({super.key, required this.mapController, required this.pickedAddress, required this.isEnabled, this.isPickedUp, this.hint, this.fromDialog = false});

  @override
  Widget build(BuildContext context) {
    return LocationSearchDialog(mapController: mapController, child: Container(
      height: fromDialog! ? 40 : 50,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSmall),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
        border: isEnabled != null ? Border.all(
          color: fromDialog! ? context.outlineVariant : isEnabled! ? context.primary : context.outline, width: isEnabled! ? fromDialog! ? 1 : 2 : 1,
        ) : null,
      ),
      child: Row(children: [
        (pickedAddress != null && pickedAddress!.isNotEmpty) ? Icon(
          Icons.location_on, size: 25,
          color: (isEnabled == null || isEnabled!) ? context.primary : context.iconBaseMedium,
        ) : Text('search_location'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
        const SizedBox(width: Dimensions.padding2xSmall),

        Expanded(
          child: (pickedAddress != null && pickedAddress!.isNotEmpty) ? Text(
            pickedAddress!,
            style: context.subHeading.defaultSize.regular, maxLines: 1, overflow: TextOverflow.ellipsis,
          ) : Text(
            hint ?? '',
            style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSmall),
        Icon(CupertinoIcons.search, size: 25, color: fromDialog! ? context.iconDisabledDefault : Theme.of(context).textTheme.bodyLarge!.color),
      ]),
    ));
  }
}
