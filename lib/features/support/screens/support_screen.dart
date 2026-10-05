import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: context.surfaceContainer,
      appBar: CustomAppBarWidget(title: 'help_and_support'.tr),
      body: SingleChildScrollView(
          child: Column(children: [

            Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraOverLarge, bottom: Dimensions.paddingDefault),
              child: CustomAssetImageWidget(
                Images.helpAndSupportBg,
                height: 120, width: 170,
              ),
            ),

            Text('contact_for_support'.tr, style: context.heading.large.strong),
            const SizedBox(height: Dimensions.padding2xSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'contact_for_support_description'.tr,
                textAlign: TextAlign.center,
                style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
              ),
            ),
            const SizedBox(height: 50),

            Container(
              padding: EdgeInsets.all(Dimensions.paddingExtraLarge),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.paddingSizeExtraOverLarge),
                  topRight: Radius.circular(Dimensions.paddingSizeExtraOverLarge),
                ),
              ),
              child: Column(children: [

                SupportCard(
                    title: 'call_our_customer_support'.tr,
                    description: 'talk_with_our_customer_support_executive_at_any_time'.tr,
                    icon: Icons.phone,
                    contactInfo: Get.find<SplashController>().configModel?.phone ?? '',
                    onTap: () async {
                      if(await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                        launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication);
                      }else {
                        showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
                      }
                    }
                ),
                const SizedBox(height: Dimensions.paddingLarge),

                SupportCard(
                  title: 'send_us_email_through'.tr,
                  description: 'typically_the_support_team_send_you_any_feedback_in_2_hours'.tr,
                  icon: Icons.email,
                  contactInfo: Get.find<SplashController>().configModel?.email ?? '',
                  onTap: () {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: Get.find<SplashController>().configModel!.email,
                    );
                    launchUrlString(emailLaunchUri.toString(), mode: LaunchMode.externalApplication);
                  },
                ),
                const SizedBox(height: Dimensions.paddingLarge),

                SupportCard(
                  title: 'address'.tr,
                  description: Get.find<SplashController>().configModel?.address ?? '',
                  icon: Icons.location_on,
                  isAddress: true,
                ),

              ]),
            ),

          ]),
        ),
    );
  }
}

class SupportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? contactInfo;
  final Function()? onTap;
  final bool isAddress;
  const SupportCard({super.key, required this.title, required this.description, required this.icon, this.contactInfo, this.onTap, this.isAddress = false});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(Dimensions.paddingDefault),
      borderRadius: Dimensions.radiusDefault,
      child: InkWell(
        onTap: onTap,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
            padding: EdgeInsets.all(Dimensions.paddingSmall),
            child: Icon(icon, size: 20, color: context.primary),
          ),
          SizedBox(width: Dimensions.paddingDefault),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: context.subHeading.large.medium.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),
              SizedBox(height: Dimensions.padding2xSmall),

              isAddress ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(
                    description,
                    style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                  ),
                ),
                SizedBox(width: Dimensions.paddingDefault),

                Container(
                  decoration: BoxDecoration(
                    color: context.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(Dimensions.padding2xSmall),
                  child: Icon(icon, color: context.surfaceContainer),
                ),
              ]) : Text(
                description,
                style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
              ),
              SizedBox(height: Dimensions.paddingSmall),

              !isAddress ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text(
                    contactInfo ?? '',
                    style: context.heading.defaultSize.strong,
                  ),
                ),
                SizedBox(width: Dimensions.paddingDefault),

                Container(
                  decoration: BoxDecoration(
                    color: context.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(Dimensions.padding2xSmall),
                  child: Icon(icon, color: context.surfaceContainer),
                ),
              ]) : SizedBox(),
            ]),
          ),

        ]),
      ),
    );
  }
}
