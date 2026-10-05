import 'package:stackfood_multivendor/features/notification/domain/models/notification_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';


class NotificationDialogWidget extends StatelessWidget {
  final NotificationModel notificationModel;
  const NotificationDialogWidget({super.key, required this.notificationModel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge))),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              (notificationModel.imageFullUrl != null && notificationModel.imageFullUrl!.isNotEmpty) ? Container(
                height: 150, width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: context.primary.withValues(alpha: 0.20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: CustomImageWidget(
                    placeholder: Images.placeholderPng,
                    image: '${notificationModel.imageFullUrl}',
                    height: 150, width: MediaQuery.of(context).size.width, fit: BoxFit.cover,
                  ),
                ),
              ) : SizedBox(
                height: 100, width: 100,
                child: ClipOval(
                  child: CustomAssetImageWidget(Images.orderPlaceHolder),
                ),
              ),
              const SizedBox(height: Dimensions.paddingLarge),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: (notificationModel.imageFullUrl != null && notificationModel.imageFullUrl!.isNotEmpty)
                    ? Dimensions.paddingLarge : 0),
                child: Text(
                  notificationModel.data!.title!,
                  textAlign: TextAlign.center,
                  style: context.heading.large.medium.overrideWith(color: context.primary),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Text(
                  notificationModel.data!.description!,
                  textAlign: TextAlign.center,
                  style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
