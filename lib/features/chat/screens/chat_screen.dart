import 'dart:async';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/chat/widgets/conversion_details_shimmer.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor/features/chat/domain/models/conversation_model.dart';
import 'package:stackfood_multivendor/features/chat/widgets/message_bubble_widget.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/common/enums/user_type.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final User? user;
  final int? conversationID;
  final int? index;
  final bool fromNotification;
  const ChatScreen({super.key, required this.notificationBody, required this.user, this.conversationID, this.index,  this.fromNotification = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();
  final FocusNode _inputMessageFocus = FocusNode();
  StreamSubscription? _stream;

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<ChatController>().getMessages(1, widget.notificationBody, widget.user, widget.conversationID, firstLoad: true);

      if(Get.find<ProfileController>().userInfoModel == null || Get.find<ProfileController>().userInfoModel!.userInfo == null) {
        Get.find<ProfileController>().getUserInfo();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<ChatController>(builder: (chatController) {

      bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

      return PopScope(
        canPop: Navigator.canPop(context),
        onPopInvokedWithResult: (didPop, result) async{
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            return;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            backgroundColor: context.surfaceContainer,
            surfaceTintColor: context.surfaceContainer,
            leading: IconButton(
              onPressed: () {
                if(widget.fromNotification) {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }else {
                  Get.back();
                }
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            title: Row(children: [

              ClipOval(child: CustomImageWidget(
                image: '${chatController.messageModel != null ? chatController.messageModel!.conversation!.receiver!.imageFullUrl : ''}',
                fit: BoxFit.cover, height: 35, width: 35,
              )),
              const SizedBox(width: Dimensions.paddingSmall),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                chatController.messageModel != null ? Text(
                  '${chatController.messageModel!.conversation!.receiver!.fName}'
                    ' ${chatController.messageModel!.conversation!.receiver!.lName}',
                  style: context.subHeading.defaultSize.regular,
                ) : Container(
                  height: 20, width: 100, color: Theme.of(context).shadowColor,
                ),

                (chatController.messageModel != null && chatController.messageModel!.conversation!.receiver!.phone != null) ? Text(
                  '${chatController.messageModel!.conversation!.receiver!.phone}',
                  style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                ) : const SizedBox(),

              ]),

            ]),
          ),

          body: isLoggedIn ? SafeArea(
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: isDesktop ? BoxDecoration(
                        color: context.surfaceContainer,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10)],
                      ) : null,
                      width: isDesktop ? Dimensions.webMaxWidth : MediaQuery.of(context).size.width,
                      margin: isDesktop ? const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge) : null,
                      child: Column(children: [

                        isDesktop ? Container(
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                          ),
                          padding: const EdgeInsets.all(Dimensions.paddingSmall),
                          margin: const EdgeInsets.all(Dimensions.paddingSmall),
                          child: Row(children: [

                            ClipOval(child: CustomImageWidget(
                              image:'${chatController.messageModel != null ? chatController.messageModel!.conversation!.receiver!.imageFullUrl : ''}',
                              fit: BoxFit.cover, height: 35, width: 35,
                            )),
                            const SizedBox(width: Dimensions.paddingSmall),

                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              chatController.messageModel != null ? Text(
                                '${chatController.messageModel!.conversation!.receiver!.fName}'
                                    ' ${chatController.messageModel!.conversation!.receiver!.lName}',
                                style: context.subHeading.defaultSize.regular,
                              ) : Container(
                                height: 20, width: 100, color: context.surface,
                              ),

                              (chatController.messageModel != null && chatController.messageModel!.conversation!.receiver!.phone != null) ? Text(
                                '${chatController.messageModel!.conversation!.receiver!.phone}',
                                style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                              ) : widget.user != null ? Text(
                                widget.user?.phone??'',
                                style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
                              ) : const SizedBox(),

                            ]),

                          ]),
                        ) : const SizedBox(),

                        GetBuilder<ChatController>(builder: (chatController) {
                          return Expanded(child: chatController.messageModel != null ? chatController.messageModel!.messages!.isNotEmpty ? SingleChildScrollView(
                            controller: _scrollController,
                            reverse: true,
                            child: PaginatedListViewWidget(
                              scrollController: _scrollController,
                              reverse: true,
                              totalSize: chatController.messageModel?.totalSize,
                              offset: chatController.messageModel?.offset,
                              onPaginate: (int? offset) async => await chatController.getMessages(
                                offset!, widget.notificationBody, widget.user, widget.conversationID,
                              ),
                              productView: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                reverse: true,
                                itemCount: chatController.messageModel!.messages!.length,
                                itemBuilder: (context, index) {
                                  return MessageBubbleWidget(
                                    previousMessage: index == 0 ? null : chatController.messageModel?.messages?.elementAt(index-1),
                                    currentMessage: chatController.messageModel!.messages![index],
                                    nextMessage: index == (chatController.messageModel!.messages!.length - 1) ? null : chatController.messageModel?.messages?.elementAt(index+1),
                                    user: chatController.messageModel!.conversation!.receiver,
                                    userType: widget.notificationBody!.adminId != null ? UserType.admin
                                        : widget.notificationBody!.deliverymanId != null ? UserType.delivery_man : UserType.vendor,
                                  );
                                },
                              ),
                            ),
                          ) : Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                              const CustomAssetImageWidget(
                                Images.messageEmpty,
                                height: 70, width: 70,
                              ),
                              const SizedBox(height: Dimensions.paddingSmall),

                              Text(
                                'no_message_found'.tr, style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                              ),
                            ],
                          )) : const ConversationDetailsShimmer());
                        }),

                        (chatController.messageModel != null && (chatController.messageModel!.status! || chatController.messageModel!.messages!.isEmpty)) ? Container(
                          decoration: BoxDecoration(
                            color: context.surfaceContainer,
                            borderRadius: isDesktop ? BorderRadius.circular(Dimensions.radiusExtraSmall) : null,
                          ),
                          margin: isDesktop ? EdgeInsets.only(bottom: Dimensions.paddingSmall, left: Dimensions.paddingSmall, right: Dimensions.paddingSmall) : EdgeInsets.zero,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            chatController.takeImageLoading && !isDesktop ? const LinearProgressIndicator(minHeight: 2) : const SizedBox(),

                            GetBuilder<ChatController>(builder: (chatController) {

                              if(chatController.pickedWebVideoFile != null && isDesktop) {
                                return Container(
                                  width: 250,
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainer,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                                    const Icon(Icons.video_collection, size: 30),
                                    const SizedBox(width: Dimensions.padding2xSmall,),

                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                                      Text(chatController.pickedWebVideoFile!.files.first.name,
                                        maxLines: 2, overflow: TextOverflow.ellipsis,
                                        style: context.subHeading.defaultSize.strong,
                                      ),
                                    ])),


                                    InkWell(
                                      onTap: () {
                                        chatController.pickVideoFile(true);
                                      },
                                      child: Padding(padding: const EdgeInsets.only(top: 5),
                                        child: Align(alignment: Alignment.topRight,
                                          child: Icon(Icons.close,
                                            size: Dimensions.paddingLarge,
                                            color: context.textBaseMedium,
                                          ),
                                        ),
                                      ),
                                    )

                                  ]),
                                );
                              }
                              if(chatController.objWebFile.isNotEmpty && isDesktop){
                                return SizedBox(
                                  height: 70,
                                  child: ListView.separated(
                                    shrinkWrap: true, scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(bottom: 0, top: 5),
                                    separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingDefault),
                                    itemCount: chatController.objWebFile.length,
                                    itemBuilder: (context, index){
                                      return Container(
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: context.surfaceContainer,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        ),
                                        padding: const EdgeInsets.only(left: 10, right: 5),
                                        child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                                          CustomAssetImageWidget(Images.fileIcon,height: 30, width: 30),
                                          const SizedBox(width: Dimensions.padding2xSmall,),

                                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                                            Text(chatController.objWebFile[index].names.first??'attachment'.tr,
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                              style: context.subHeading.defaultSize.strong,
                                            ),
                                          ])),


                                          InkWell(
                                            onTap: () {
                                              chatController.pickFile(true, index: index);
                                            },
                                            child: Padding(padding: const EdgeInsets.only(top: 5),
                                              child: Align(alignment: Alignment.topRight,
                                                child: Icon(Icons.close,
                                                  size: Dimensions.paddingLarge,
                                                  color: context.textBaseMedium,
                                                ),
                                              ),
                                            ),
                                          )

                                        ]),
                                      );
                                    },
                                  ),
                                );
                              }

                              if(chatController.pickedVideoFile != null) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 250,
                                    decoration: BoxDecoration(
                                      color: context.surfaceContainer,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    margin: const EdgeInsets.only(top: 10, left: Dimensions.paddingDefault),
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [

                                      Icon(Icons.video_file, size: 35, color: context.iconBaseMedium),
                                      const SizedBox(width: Dimensions.padding2xSmall,),

                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                                        Text(chatController.pickedVideoFile!.name,
                                          maxLines: 2, overflow: TextOverflow.ellipsis,
                                          style: context.subHeading.defaultSize.strong,
                                        ),

                                        Text('${chatController.videoSize.toStringAsFixed(2)}MB', style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium)),
                                      ])),


                                      InkWell(
                                        onTap: () {
                                          chatController.pickVideoFile(true);
                                        },
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(Icons.close,
                                            size: Dimensions.paddingLarge,
                                            color: context.iconBaseMedium,
                                          ),
                                        ),
                                      )

                                    ]),
                                  ),
                                );
                              }

                              if(chatController.objFile.isNotEmpty){
                                return SizedBox(
                                  height: 70,
                                  child: ListView.separated(
                                    shrinkWrap: true, scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(bottom: 0, top: 10, left: Dimensions.paddingDefault, right: Dimensions.paddingDefault),
                                    separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingDefault),
                                    itemCount: chatController.objFile.length,
                                    itemBuilder: (context, index){

                                      return Container(
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: context.surfaceContainer,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        ),
                                        padding: const EdgeInsets.only(left: 10, right: 5),
                                        child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                                          CustomAssetImageWidget(Images.fileIcon, height: 30, width: 30),
                                          const SizedBox(width: Dimensions.padding2xSmall,),

                                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                                            Text(chatController.objFile[index].name,
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                              style: context.subHeading.defaultSize.strong,
                                            ),

                                            Text('${chatController.fileSizeList[index].toStringAsFixed(2)} MB', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
                                          ])),


                                          InkWell(
                                            onTap: () {
                                              chatController.pickFile(true, index: index);
                                            },
                                            child: Padding(padding: const EdgeInsets.only(top: 5),
                                              child: Align(alignment: Alignment.topRight,
                                                child: Icon(Icons.close,
                                                  size: Dimensions.paddingLarge,
                                                  color: context.iconBaseMedium,
                                                ),
                                              ),
                                            ),
                                          )

                                        ]),
                                      );
                                    },
                                  ),
                                );
                              }

                              if(chatController.chatImage.isNotEmpty && !chatController.isLoading) {
                                return SizedBox(
                                  height: 70,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: chatController.chatImage.length,
                                    itemBuilder: (BuildContext context, index){
                                      return  chatController.chatImage.isNotEmpty ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: Dimensions.paddingDefault, right: Dimensions.paddingSmall,
                                          top: Dimensions.paddingDefault,
                                        ),
                                        child: Stack(clipBehavior: Clip.none, children: [

                                          Container(width: 50, height: 60,
                                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusExtraSmall)),
                                              child: Image.memory(
                                                chatController.chatRawImage[index], width: 50, height: 60, fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            top: -5, right: -10,
                                            child: InkWell(
                                              onTap : () => chatController.removeImage(index, _inputMessageController.text.trim()),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingDefault)),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: Icon(Icons.clear, color: context.surfaceContainer, size: 15),
                                                ),
                                              ),
                                            ),
                                          )],
                                        ),
                                      ) : const SizedBox();
                                    },
                                  ),
                                );
                              }

                              return const SizedBox();
                            }),

                            (chatController.isLoading && chatController.chatImage.isNotEmpty)
                                ? Align(alignment: Alignment.centerRight, child: Padding(
                                  padding: const EdgeInsets.only(right: Dimensions.paddingLarge, top: Dimensions.padding2xSmall),
                                  child: Text(
                                    '${'uploading'.tr} ${chatController.chatImage.length} ${'images'.tr}',
                                    style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
                                  ),
                                ))
                                : const SizedBox(),

                            Container(
                              margin: const EdgeInsets.all(Dimensions.paddingDefault),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [

                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: context.surfaceContainer,
                                      border: Border.all(color: context.primary.withValues(alpha: 0.5), width: 1),
                                    ),
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                      const SizedBox(width: Dimensions.paddingSmall),

                                      InkWell(
                                        onTap: () {
                                          _inputMessageFocus.unfocus();
                                          chatController.toggleEmojiPicker();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSmall + 2, right: Dimensions.paddingSmall),
                                          child: Icon(Icons.emoji_emotions_outlined, color: context.textBaseMedium),
                                        ),
                                      ),

                                      Expanded(
                                        child: TextField(
                                          inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                                          controller: _inputMessageController,
                                          focusNode: _inputMessageFocus,
                                          textCapitalization: TextCapitalization.sentences,
                                          style: context.subHeading.defaultSize.regular,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 5,
                                          minLines: 1,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'type_a_massage'.tr,
                                            hintStyle: context.body.large.regular.overrideWith(color: context.textBaseMedium),
                                          ),
                                          onTap: () {
                                            if (chatController.isEmojiPickerVisible) {
                                              chatController.toggleEmojiPicker();
                                            }
                                          },
                                          onSubmitted: (String newText) {
                                            if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                              Get.find<ChatController>().toggleSendButtonActivity();
                                            }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                              Get.find<ChatController>().toggleSendButtonActivity();
                                            }
                                          },
                                          onChanged: (String newText) {
                                            if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                              Get.find<ChatController>().toggleSendButtonActivity();
                                            }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                              Get.find<ChatController>().toggleSendButtonActivity();
                                            }
                                          },
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () async {
                                          Get.find<ChatController>().pickImage(false);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
                                          child: CustomAssetImageWidget(Images.image, width: 25, height: 25, color: context.textBaseMedium),
                                        ),
                                      ),

                                      MenuAnchor(
                                        builder: (BuildContext context, MenuController controller, Widget? child) {
                                          return InkWell(
                                            onTap: () async {
                                              _inputMessageFocus.unfocus();

                                              if (controller.isOpen) {
                                                controller.close();
                                              } else {
                                                controller.open();
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: Dimensions.paddingSmall),
                                              child: CustomAssetImageWidget(Images.file, width: 25, height: 25, color: context.textBaseMedium),
                                            ),
                                          );
                                        },
                                        menuChildren: List<MenuItemButton>.generate(2, (int index) => MenuItemButton(
                                            onPressed: () {
                                              if(index == 0) {
                                                Get.find<ChatController>().pickFile(false);
                                              } else {
                                                Get.find<ChatController>().pickVideoFile(false);
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Icon(index == 0 ? Icons.file_copy_outlined : Icons.video_collection_outlined, size: 18, color: context.primary),
                                                const SizedBox(width: Dimensions.paddingSmall),

                                                Text(index == 0 ? 'pick_files'.tr : 'pick_video'.tr, style: context.subHeading.defaultSize.medium),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                    ]),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSmall),

                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    color: context.surfaceContainer,
                                    border: Border.all(color: context.primary.withValues(alpha: 0.5), width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: GetBuilder<ChatController>(builder: (chatController) {
                                    return chatController.isLoading ? const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault, vertical: 7),
                                      child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
                                    ) : InkWell(
                                      onTap: () async {
                                        if(chatController.isSendButtonActive) {
                                          await chatController.sendMessage(
                                            message: _inputMessageController.text, notificationBody: widget.notificationBody,
                                            conversationID: widget.conversationID, index: widget.index,
                                          );
                                          _inputMessageController.clear();
                                        } else {
                                          showCustomSnackBar('write_something'.tr);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 6),
                                        child: CustomAssetImageWidget(
                                          Images.send, width: 40, height: 40,
                                          color: context.primary,
                                        ),
                                      ),
                                    );
                                  }
                                  ),
                                ),

                              ]),
                            ),

                            if (chatController.isEmojiPickerVisible)
                              SizedBox(
                                height: 250,
                                child: EmojiPicker(
                                  onEmojiSelected: (category, emoji) {
                                    if (!chatController.isSendButtonActive) {
                                      chatController.toggleSendButtonActivity();
                                    }
                                  },
                                  textEditingController: _inputMessageController,
                                  config: Config(
                                    checkPlatformCompatibility: true,
                                    emojiViewConfig: EmojiViewConfig(
                                      emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ?  1.20 :  1.0),
                                    ),
                                    skinToneConfig: const SkinToneConfig(),
                                    categoryViewConfig: const CategoryViewConfig(),
                                    bottomActionBarConfig: const BottomActionBarConfig(),
                                    searchViewConfig: const SearchViewConfig(),
                                  ),
                                ),
                              ),

                          ]),
                        ) : const SizedBox(),
                      ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ) : NotLoggedInScreen(callBack: (value){
            _initCall();
            setState(() {});
          }),
        ),
      );
    });
  }
}
