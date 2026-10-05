part of '../screens/home_screen.dart';


class _BadWeatherCard extends StatelessWidget {
  const _BadWeatherCard();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController) {
      final AddressModel? address = AddressHelper.getAddressFromSharedPref();

      final ZoneData? zoneData = address?.zoneData?.firstWhereOrNull(
        (data) => data.id == address.zoneId && data.increasedDeliveryFeeStatus == 1 && data.increaseDeliveryFeeMessage?.isNotEmpty == true,
      );
      if(zoneData == null) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.fromLTRB(
          Dimensions.paddingLarge,
          ResponsiveHelper.isMobile(context) ? Dimensions.paddingSmall : Dimensions.paddingSmall,
          Dimensions.paddingLarge,
          ResponsiveHelper.isMobile(context) ? Dimensions.paddingDefault : Dimensions.paddingSmall,
        ),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          decoration: BoxDecoration(
            color: context.bgWarningMedium,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          child: Row(children: [
            const CustomAssetImageWidget(Images.weather, height: 36, width: 36),
            const SizedBox(width: Dimensions.paddingSmall),

            Expanded(
              child: Text(
                zoneData.increaseDeliveryFeeMessage!,
                style: context.subHeading.defaultSize.regular.semiBold,
              ),
            ),
          ]),
        ),
      );
    });
  }
}
