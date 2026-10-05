part of '../screens/home_screen.dart';


class _BogoOfferCard extends StatelessWidget {
  const _BogoOfferCard();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BogoOfferController>(builder: (bogoOfferController) {
      final BogoHomeModel? bogoHome = bogoOfferController.bogoHomeModel;
      if(bogoHome?.isLive != true) {
        return const SizedBox.shrink();
      }

      final String title =  'hurry_up_bogo_offer_is_live'.tr;
      final String description = 'buy_more_and_enjoy_exclusive_free_items'.tr;

      return Container(
        color: context.surfaceContainer,
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingLarge,
          0,
          Dimensions.paddingLarge,
          Dimensions.paddingLarge,
        ),
        child: CustomInkWellWidget(
          onTap: (){Get.toNamed(RouteHelper.getBogoOfferRoute());},
          radius: Dimensions.radiusLarge,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingDefault),
            decoration: BoxDecoration(
              color: context.bgInfoMedium,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
            child: Row(children: [
              const CustomAssetImageWidget(Images.bogoOfferIcon, height: 40, width: 40),
              const SizedBox(width: Dimensions.paddingSmall),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.subHeading.large.semiBold),
                    const SizedBox(height: Dimensions.padding2xSmall),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.body.small.regular),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSmall),

              Icon(
                Icons.arrow_forward,
                color: context.iconBaseDefault,
                size: 20,
              ),
            ]),
          ),
        ),
      );
    });
  }
}
