import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';

class PromotionalBannerViewWidget extends StatelessWidget {
  static const double _aspectRatio = 9 / 2;

  const PromotionalBannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: CustomImageWidget(
          placeholder: Images.placeholder,
          image: '${Get.find<SplashController>().configModel!.bannerData!.promotionalBannerImageFullUrl}',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
