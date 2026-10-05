import 'package:flutter/material.dart';


import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/common/enums/user_type.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';

import 'package:get/get.dart';

class ConversationListViewWidget extends StatefulWidget {
  final ScrollController scrollController;
  final ConversationsModel? conversation;
  final ChatController chatController;
  final String type;

  const ConversationListViewWidget({super.key, required this.scrollController, required this.conversation, required this.chatController, required this.type, });

  @override
  State<ConversationListViewWidget> createState() => _ConversationListViewWidgetState();
}

class _ConversationListViewWidgetState extends State<ConversationListViewWidget> {

  @override
  void initState() {
    super.initState();

    Get.find<ChatController>().getConversationList(1, type: widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return (widget.conversation != null && widget.conversation?.conversations != null) ? widget.conversation!.conversations!.isNotEmpty ? RefreshIndicator(
      onRefresh: () async {
        await Get.find<ChatController>().getConversationList(1, type: widget.type);
      },
      child: PaginatedListViewWidget(
        scrollController: widget.scrollController,
        onPaginate: (int? offset) => widget.chatController.getConversationList(offset!),
        totalSize: widget.conversation?.totalSize,
        offset: widget.conversation?.offset ?? 1,
        enabledPagination: widget.chatController.searchConversationModel == null,
        productView: ListView.builder(
          itemCount: widget.conversation?.conversations!.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {

            User? user;
            String? type;
            if(widget.conversation!.conversations![index]!.senderType == UserType.user.name
                || widget.conversation?.conversations![index]!.senderType == UserType.customer.name) {
              user = widget.conversation?.conversations![index]!.receiver;
              type = widget.conversation?.conversations![index]!.receiverType;
            }else {
              user = widget.conversation?.conversations![index]!.sender;
              type = widget.conversation?.conversations![index]!.senderType;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),

              decoration: BoxDecoration(
                color: context.surfaceContainer, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              child: CustomInkWellWidget(
                onTap: () {
                  if(user != null) {

                    Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBodyModel(
                        type: widget.conversation!.conversations![index]!.senderType,
                        notificationType: NotificationType.message,
                        adminId: type == UserType.admin.name ? 0 : null,
                        restaurantId: type == UserType.vendor.name ? user.id : null,
                        deliverymanId: type == UserType.delivery_man.name ? user.id : null,
                      ),
                      conversationID: widget.conversation?.conversations![index]!.id,
                      index: index,
                    ));

                  }else {
                    showCustomSnackBar('${type!.tr} ${'not_found'.tr}');
                  }
                },
                highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                radius: Dimensions.radiusExtraSmall,
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSmall),
                    child: Row(children: [
                      ClipOval(child: CustomImageWidget(
                        height: 50, width: 50,
                        image: '${user != null ? user.imageFullUrl : ''}',
                      )),
                      const SizedBox(width: Dimensions.paddingSmall),

                      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                        user != null ? Text(
                          '${user.fName} ${user.lName}', style: context.subHeading.defaultSize.medium,
                        ) : Text('${type!.tr} ${'deleted'.tr}', style: context.subHeading.defaultSize.medium),
                        const SizedBox(height: Dimensions.padding2xSmall),

                        user != null ? Text(
                          type!.tr,
                          style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                        ) : const SizedBox(),
                      ])),
                    ]),
                  ),

                  Positioned(
                    right: Get.find<LocalizationController>().isLtr ? 5 : null, bottom: 5, left: Get.find<LocalizationController>().isLtr ? null : 5,
                    child: Text(
                      DateConverter.localDateToIsoStringAMPM(DateConverter.dateTimeStringToDate(
                          widget.conversation!.conversations![index]!.lastMessageTime!)),
                      style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                    ),
                  ),

                  GetBuilder<ProfileController>(builder: (profileController) {
                    return (profileController.userInfoModel != null && profileController.userInfoModel!.userInfo != null
                        && widget.conversation!.conversations![index]!.lastMessage!.senderId != profileController.userInfoModel!.userInfo!.id
                        && widget.conversation!.conversations![index]!.unreadMessageCount! > 0) ? Positioned(
                          right: Get.find<LocalizationController>().isLtr ? 5 : null, top: 5, left: Get.find<LocalizationController>().isLtr ? null : 5,
                          child: Container(
                            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                            decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
                            child: Text(
                              widget.conversation!.conversations![index]!.unreadMessageCount.toString(),
                              style: context.subHeading.extraSmall.medium.overrideWith(color: context.surfaceContainer),
                            ),
                          ),
                    ) : const SizedBox();
                  }),

                ]),
              ),
            );
          },
        ),
      ),
    ) : Center(child: Text('no_conversation_found'.tr)) : const Center(child: CircularProgressIndicator());

  }
}

class ConversationShimmer extends StatelessWidget {
  const ConversationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
            decoration: BoxDecoration(
              color: context.surfaceContainer, borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
              boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 5)],
            ),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSmall),
                child: Column(
                  children: [

                    Row(children: [

                      ClipOval(child: Container(height: 50, width: 50, color: Colors.grey[300])),
                      const SizedBox(width: Dimensions.paddingSmall),

                      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Container(height: 10, width: Get.width * 0.5, color: Colors.grey[300]),
                        const SizedBox(height: Dimensions.padding2xSmall),

                        Container(height: 10, width: Get.width * 0.3, color: Colors.grey[300]),

                      ])),
                    ]),

                    Divider(),

                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
