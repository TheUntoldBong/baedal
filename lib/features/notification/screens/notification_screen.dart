import 'package:stackfood_multivendor/common/enums/order_status.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/notification/widgets/add_fund_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/notification/widgets/notification_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/notification/widgets/notification_dialog_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController scrollController = ScrollController();

  void _loadData() async {
    Get.find<NotificationController>().clearNotification();
    if(Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(true);
    }
    if(Get.find<AuthController>().isLoggedIn() && (Get.find<ProfileController>().userInfoModel?.walletBalance == null)) {
      await Get.find<ProfileController>().getUserInfo();
    }
  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {


    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: context.surface,
        appBar: CustomAppBarWidget(title: 'notification'.tr, onBackPressed: () {
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }else {
            Get.back();
          }
        }, actions: [
          GetBuilder<NotificationController>(builder: (notificationController) {
            if(!Get.find<AuthController>().isLoggedIn() || notificationController.unseenCount == 0) {
              return const SizedBox();
            }
            return TextButton(
              onPressed: notificationController.markAllAsSeen,
              child: Text('mark_all_as_read'.tr, style: context.subHeading.small.medium.overrideWith(color: context.primary)),
            );
          }),
        ]),
        body: Get.find<AuthController>().isLoggedIn() ? GetBuilder<NotificationController>(builder: (notificationController) {
          List<DateTime> dateTimeList = [];
          return notificationController.notificationList != null ? notificationController.notificationList!.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              await notificationController.getNotificationList(true);
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                child: Column(children: [
                  Center(child: SizedBox(width: Dimensions.webMaxWidth, child: ListView.builder(
                    itemCount: notificationController.notificationList!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DateTime originalDateTime = DateConverter.dateTimeStringToDate(notificationController.notificationList![index].createdAt!);
                      DateTime convertedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
                      bool addTitle = false;
                      if(!dateTimeList.contains(convertedDate)) {
                        addTitle = true;
                        dateTimeList.add(convertedDate);
                      }
                      bool isSeen = notificationController.isSeen(notificationController.notificationList![index].id);

                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        addTitle ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge, horizontal: Dimensions.paddingLarge),
                          child: Text(
                            DateConverter.dateTimeStringToDateOnly(notificationController.notificationList![index].createdAt!),
                            style: context.subHeading.defaultSize.semiBold,
                          ),
                        ) : const SizedBox(),

                        InkWell(
                          onTap: () {
                            notificationController.addSeenNotificationId(notificationController.notificationList![index].id!);

                            if(notificationController.notificationList![index].data!.type == 'push_notification' || notificationController.notificationList![index].data!.type == 'referral_code'
                               || notificationController.notificationList![index].data!.type == 'referral_earn'){
                              ResponsiveHelper.isDesktop(context) ? showDialog(context: context, builder: (BuildContext context) {
                                return NotificationDialogWidget(notificationModel: notificationController.notificationList![index]);
                              }) : showModalBottomSheet(
                                isScrollControlled: true, useRootNavigator: true, context: Get.context!,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
                                ),
                                builder: (context) {
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                    child: NotificationBottomSheet(notificationModel: notificationController.notificationList![index]),
                                  );
                                },
                              );
                            }else if(notificationController.notificationList![index].data!.type == 'order_status'){
                              if(notificationController.notificationList![index].data!.orderStatus == OrderStatus.picked_up.name
                                  || notificationController.notificationList![index].data!.orderStatus == OrderStatus.handover.name) {
                                Get.toNamed(RouteHelper.getOrderTrackingRoute(notificationController.notificationList![index].data!.orderId!, null));
                              }else {
                                Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationController.notificationList![index].data!.orderId!, fromGuestTrack: true));
                              }
                            } else if (notificationController.notificationList![index].data!.type == 'add_fund') {
                              ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                                AddFundBottomSheet(notificationModel: notificationController.notificationList![index]),
                                backgroundColor: Colors.transparent, isScrollControlled: true,
                              ) : Get.dialog(
                                Dialog(child: AddFundBottomSheet(notificationModel: notificationController.notificationList![index])),
                              );
                            }

                          },
                          child: Container(
                            color: isSeen ? context.surface : context.bgInfoLight,
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge, horizontal: Dimensions.paddingLarge),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              CustomAssetImageWidget(
                                notificationController.notificationList![index].data!.type == 'push_notification' ? Images.pushNotificationIcon
                                : notificationController.notificationList![index].data!.type == 'referral_code' ? Images.referPersonIcon
                                : notificationController.notificationList![index].data!.type == 'referral_earn' ? Images.referEarnIcon
                                : notificationController.notificationList![index].data!.orderStatus == OrderStatus.picked_up.name
                                || notificationController.notificationList![index].data!.orderStatus == OrderStatus.handover.name ? Images.orderOnTheWaYIcon : Images.orderConfirmIcon,
                                height: 34, width: 34, fit: BoxFit.cover,
                              ),
                              const SizedBox(width: Dimensions.paddingSmall),

                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Expanded(
                                    child: Text(
                                      notificationController.notificationList![index].data!.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: isSeen
                                          ? context.heading.defaultSize.medium.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5))
                                          : context.heading.defaultSize.strong.overrideWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(left: Dimensions.paddingSmall),
                                    child: Text(
                                      DateConverter.dateTimeStringToFormattedTime(notificationController.notificationList![index].updatedAt!),
                                      style: context.body.small.regular.overrideWith(color: isSeen ? context.textBaseMedium : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5)),
                                    ),
                                  ),

                                ]),
                                const SizedBox(height: Dimensions.padding2xSmall),

                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Expanded(
                                    child: Text(
                                      notificationController.notificationList![index].data!.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: context.body.defaultSize.regular.overrideWith(color: isSeen ? context.textBaseMedium : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7)),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSmall),

                                  (notificationController.notificationList![index].data!.type == 'push_notification') && notificationController.notificationList![index].imageFullUrl != null
                                      && notificationController.notificationList![index].imageFullUrl!.isNotEmpty ? ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                    child: CustomImageWidget(
                                      placeholder: Images.placeholderPng,
                                      image: '${notificationController.notificationList![index].imageFullUrl}',
                                      height: 45, width: 75, fit: BoxFit.cover,
                                    ),
                                  ) : const SizedBox.shrink(),
                                ]),

                              ])),

                            ]),
                          ),
                        ),

                        Divider(height: 1, color: context.surfaceContainer,),

                      ]);
                    },
                  ))),
                ],
                ),
              ),
            ),
          ) : NoDataScreen(title: 'no_notification'.tr, isEmptyNotification: true) : const Center(child: CircularProgressIndicator());
        }) : NotLoggedInScreen(callBack: (value){
          _loadData();
          setState(() {});
        }),
      ),
    );
  }
}
