import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/chat/widgets/chat_serach_field_widget.dart';
import 'package:stackfood_multivendor/features/chat/widgets/message_card_widget.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/common/enums/user_type.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>  with TickerProviderStateMixin{
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _initCall();
    _scrollController.addListener(() {
      if(_scrollController.offset < 105) {
        Get.find<ChatController>().canShowFloatingButton(false);
      } else {
        Get.find<ChatController>().canShowFloatingButton(true);
      }
    });
  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<ChatController>().setType('vendor', willUpdate: false);
      Get.find<ChatController>().getConversationList(1, type: Get.find<ChatController>().type);
      Get.find<ChatController>().getAdminConversationList();
    }
  }

  void _decideResult(ConversationsModel? conversation) {
    String? type = 'vendor';
    if(conversation != null && conversation.conversations != null && conversation.conversations!.isNotEmpty) {
      if (conversation.conversations?.first?.senderType == UserType.user.name
          || conversation.conversations?.first?.senderType == UserType.customer.name) {
        type = conversation.conversations?.first?.receiverType;
      } else {
        type = conversation.conversations?.first?.senderType;
      }
    }

    if(type == 'delivery_man' && !_tabController.indexIsChanging) {
      _tabController.animateTo(1);
      Get.find<ChatController>().setType('delivery_man');
      Get.find<ChatController>().setTabSelect();
    } else if(type == 'vendor' && !_tabController.indexIsChanging) {
      _tabController.animateTo(0);
      Get.find<ChatController>().setType('vendor');
      Get.find<ChatController>().setTabSelect();
    }

  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ChatController>(builder: (chatController) {
      ConversationsModel? conversation;
      if(chatController.searchConversationModel != null) {
        conversation = chatController.searchConversationModel;
        _decideResult(chatController.searchConversationModel);
      }else {
        conversation = chatController.conversationModel;
      }

      return Scaffold(
        appBar: CustomAppBarWidget(title: 'conversation_list'.tr),
        floatingActionButton: !ResponsiveHelper.isDesktop(context) ? (chatController.conversationModel != null && chatController.showFloatingButton) ? FloatingActionButton(
          backgroundColor: context.primary,
          onPressed: () => Get.toNamed(RouteHelper.getChatRoute(notificationBody: NotificationBodyModel(
            notificationType: NotificationType.message, adminId: 0,
          ))),
          child: CustomImageWidget(
            image: Get.find<SplashController>().configModel?.favIconFullUrl ?? '',
          ),
        ) : null : null,

        body: Column(children: [

        (Get.find<AuthController>().isLoggedIn() && conversation != null) ? Center(child: Container(
          width: Dimensions.webMaxWidth,
          padding: const EdgeInsets.all(Dimensions.paddingDefault),
          child: ChatSearchFieldWidget(
          controller: _searchController,
          hint: '${'search'.tr}.....',
          suffixIcon: chatController.searchConversationModel != null ? Icons.close : CupertinoIcons.search,
          onSubmit: (String text) {
            if(_searchController.text.trim().isNotEmpty) {
              chatController.searchConversation(_searchController.text.trim());
            }else {
              showCustomSnackBar('write_something'.tr);
            }
          },
          iconPressed: () {
            if(chatController.searchConversationModel != null) {
              _searchController.text = '';
              chatController.removeSearchMode();
              chatController.getConversationList(1, type: chatController.type);
            } else {
              if(_searchController.text.trim().isNotEmpty) {
                chatController.searchConversation(_searchController.text.trim());
              }else {
                showCustomSnackBar('write_something'.tr);
              }
            }
          },
        ))) : const SizedBox(),

        Expanded(child: Get.find<AuthController>().isLoggedIn() ? (conversation != null) ? RefreshIndicator(
          onRefresh: () async {
            await Get.find<ChatController>().getConversationList(1, type: chatController.type);
          },
          child: CustomScrollView(controller: _scrollController, slivers: [

            SliverToBoxAdapter(child: chatController.conversationModel != null ? Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingDefault, right: Dimensions.paddingDefault, bottom: Dimensions.paddingSmall, top: Dimensions.padding2xSmall),
              child: Builder(
                builder: (context) {
                  int adminUnreadCount = 0;
                  if(chatController.adminConversationModel != null) {
                    if(Get.find<ProfileController>().userInfoModel != null && Get.find<ProfileController>().userInfoModel!.userInfo != null
                        && chatController.adminConversationModel!.lastMessage!.senderId == Get.find<ProfileController>().userInfoModel!.userInfo!.id) {
                      adminUnreadCount = 0;
                    } else {
                      adminUnreadCount = chatController.adminConversationModel!.unreadMessageCount ?? 0;
                    }

                  }
                  return MessageCardWidget(
                    userTypeImage: Get.find<SplashController>().configModel?.favIconFullUrl ?? '',
                    userType: Get.find<SplashController>().configModel?.businessName ?? '',
                    count: adminUnreadCount,
                    message: chatController.adminConversationModel?.lastMessage?.message ?? 'chat_with_admin'.tr,
                    time: chatController.adminConversationModel?.lastMessageTime != null ? DateConverter.stringDateTimeToDate(chatController.adminConversationModel!.lastMessageTime!) : '',
                    onTap: () {
                      Get.toNamed(RouteHelper.getChatRoute(notificationBody: NotificationBodyModel(
                        notificationType: NotificationType.message, adminId: 0,
                      )))?.then((value) => Get.find<ChatController>().getConversationList(1, type: chatController.type));
                    },
                  );
                }
              ),
            ) : const SizedBox()),

            SliverPersistentHeader(
              pinned: true,
              delegate: SliverDelegate(child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
                child: TabBar(
                  tabAlignment: TabAlignment.start,
                  controller: _tabController,
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.only(right: Dimensions.paddingDefault),
                  indicatorColor: context.primary,
                  labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                  unselectedLabelColor: context.textBaseMedium,
                  indicatorSize: TabBarIndicatorSize.label,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelStyle: context.subHeading.defaultSize.strong,
                  unselectedLabelStyle: context.subHeading.defaultSize.regular,
                  tabs: [
                    Tab(text: 'restaurants'.tr),
                    Tab(text: 'delivery_man'.tr),
                  ],
                  onTap: (int index){

                    if(index == 0){
                      chatController.setType('vendor');
                      chatController.setTabSelect();
                    } else {
                      chatController.setType('delivery_man');
                      chatController.setTabSelect();
                    }
                    if(chatController.searchConversationModel == null) {
                      chatController.getConversationList(1, type: chatController.type);
                    }
                  },
                ),
              )),
            ),

            SliverToBoxAdapter(
              child: conversation.conversations != null ? conversation.conversations!.isNotEmpty
                  ? conversationCart(chatController, conversation)
                  : Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(child: Column(
                  children: [
                    const CustomAssetImageWidget(
                      Images.messageEmpty,
                      height: 70, width: 70,
                    ),
                    const SizedBox(height: Dimensions.paddingSmall),

                    Text(
                      'no_conversation_found'.tr,
                      style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                    ),
                  ],
                )),
              ) : const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(child: CircularProgressIndicator()),
              ),

            ),

          ]),
        ) : const Center(child: CircularProgressIndicator()) :  NotLoggedInScreen(callBack: (value){
          _initCall();
          setState(() {});
        })),

        ]),

      );
    });
  }

  Widget conversationCart(ChatController chatController, ConversationsModel? conversation) {
    return !chatController.tabLoading ? Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.all(Dimensions.paddingDefault),
      child: PaginatedListViewWidget(
        scrollController: _scrollController,
        onPaginate: (int? offset) => chatController.getConversationList(offset!, type: chatController.type),
        totalSize: conversation?.totalSize,
        offset: conversation?.offset,
        enabledPagination: chatController.searchConversationModel == null,
        productView: ListView.builder(
          itemCount: conversation?.conversations!.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {

            User? user;
            String? type;
            if(conversation!.conversations![index]!.senderType == UserType.user.name
                || conversation.conversations![index]!.senderType == UserType.customer.name) {
              user = conversation.conversations![index]!.receiver;
              type = conversation.conversations![index]!.receiverType;
            }else {
              user = conversation.conversations![index]!.sender;
              type = conversation.conversations![index]!.senderType;
            }

            String? lastMessage = _lastMessage(conversation.conversations![index]);

            bool unSeen =  (Get.find<ProfileController>().userInfoModel != null && Get.find<ProfileController>().userInfoModel!.userInfo != null
                && conversation.conversations![index]!.lastMessage!.senderId != Get.find<ProfileController>().userInfoModel!.userInfo?.id
                && conversation.conversations![index]!.unreadMessageCount! > 0);

            return (type == UserType.admin.name) ? const SizedBox() : (type == chatController.type) ? Container(
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSmall),
              decoration: BoxDecoration(
                color: unSeen ? context.primary.withValues(alpha: 0.1) : context.surfaceContainer,
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                boxShadow: [BoxShadow(color: unSeen ? context.surfaceContainer : Colors.black.withValues(alpha: 0.05), blurRadius: 5, spreadRadius: 0)],
              ),
              child: CustomInkWellWidget(
                onTap: () async {
                  if(user != null) {

                    await Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBodyModel(
                        type: conversation.conversations![index]!.senderType,
                        notificationType: NotificationType.message,
                        adminId: type == UserType.admin.name ? 0 : null,
                        restaurantId: type == UserType.vendor.name ? user.id : null,
                        deliverymanId: type == UserType.delivery_man.name ? user.id : null,
                      ),
                      conversationID: conversation.conversations![index]!.id,
                      index: index,
                    ));
                    Get.find<ChatController>().getConversationList(1, type: Get.find<ChatController>().type);

                  } else {
                    showCustomSnackBar('${type!.tr} ${'not_found'.tr}');
                  }
                },
                highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                radius: Dimensions.radiusExtraSmall,
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.paddingLarge),
                  child: Row(children: [

                    ClipOval(child: CustomImageWidget(
                      height: 50, width: 50,
                      image: '${user != null ? user.imageFullUrl : ''}',
                    )),
                    const SizedBox(width: Dimensions.paddingSmall),

                    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        user != null ? Text(
                          '${user.fName} ${user.lName}', style: context.subHeading.defaultSize.medium,
                        ) : Text('${type!.tr} ${'deleted'.tr}', style: context.subHeading.defaultSize.medium),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateConverter.convertTodayYesterdayDate(conversation.conversations![index]!.lastMessageTime!),
                            style: context.body.extraSmall.regular.overrideWith(color: context.textBaseMedium),
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.padding2xSmall),

                      Row(children: [
                        user != null ? Expanded(
                          child: Text(
                            lastMessage ?? 'start_conversation'.tr,
                            style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: Dimensions.paddingDefault),

                        GetBuilder<ProfileController>(builder: (profileController) {
                          return (profileController.userInfoModel != null && profileController.userInfoModel!.userInfo != null
                              && conversation.conversations![index]!.lastMessage!.senderId != profileController.userInfoModel!.userInfo!.id
                              && conversation.conversations![index]!.unreadMessageCount! > 0) ? Container(
                            padding: const EdgeInsets.all(Dimensions.padding2xSmall),
                            decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
                            child: Text(
                              conversation.conversations![index]!.unreadMessageCount.toString(),
                              style: context.subHeading.extraSmall.medium.overrideWith(color: context.surfaceContainer),
                            ),
                          ) : const SizedBox();
                        }),
                      ]),
                    ])),
                  ]),
                ),
              ),
            ) : const SizedBox();
          },
        ),
      ),
    ) : const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  String? _lastMessage(Conversation? conversation) {
    if(conversation != null && conversation.lastMessage != null) {
      if(conversation.lastMessage!.message != null) {
        return conversation.lastMessage!.message;
      }
      else if(conversation.lastMessage!.filesFullUrl!.isNotEmpty) {
        return '${conversation.lastMessage!.filesFullUrl!.length} ${'attachment'.tr}';
      }
    }
    return null;
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}