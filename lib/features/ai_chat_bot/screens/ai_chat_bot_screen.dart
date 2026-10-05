import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/controllers/ai_chat_bot_controller.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/domain/models/ai_chat_conversation_model.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_conversation_card_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_conversation_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_empty_state_widget.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatBotScreen extends StatefulWidget {
  const AiChatBotScreen({super.key});

  @override
  State<AiChatBotScreen> createState() => _AiChatBotScreenState();
}

class _AiChatBotScreenState extends State<AiChatBotScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    Get.find<AiChatBotController>().getConversationList(1, reload: true);
  }

  Future<void> _confirmDelete(AiChatConversation conversation) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_conversation'.tr, style: context.heading.large.strong),
        content: Text(
          'delete_conversation_confirm'.tr,
          style: context.body.small.regular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'cancel'.tr,
              style: context.body.defaultSize.medium.overrideWith(color: context.textBaseMedium),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'delete'.tr,
              style: context.body.defaultSize.medium.overrideWith(color: context.textDangerDefault),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || conversation.id == null) {
      return;
    }

    final bool ok = await Get.find<AiChatBotController>().deleteConversation(conversation.id!);
    showCustomSnackBar(
      ok ? 'conversation_deleted'.tr : 'sorry_something_went_wrong'.tr,
      isError: !ok,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      appBar: CustomAppBarWidget(title: 'ai_chat_bot'.tr),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(RouteHelper.getAiChatDetailsScreen(conversationId: null)),
        icon: Icon(Icons.add_rounded, color: context.onPrimary),
        label: Text(
          'new_chat'.tr,
          style: context.body.defaultSize.medium.overrideWith(color: context.onPrimary),
        ),
        backgroundColor: context.primary,
      ),
      body: GetBuilder<AiChatBotController>(builder: (aiChatBotController) {
        if (aiChatBotController.conversationModel == null) {
          return const AiChatConversationShimmerWidget();
        }
        if (aiChatBotController.conversationModel!.data == null
            || aiChatBotController.conversationModel!.data!.isEmpty) {
          return const AiChatEmptyStateWidget();
        }
        return RefreshIndicator(
          onRefresh: () async {
            await Get.find<AiChatBotController>().getConversationList(1, reload: true);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSmall,
              vertical: Dimensions.paddingSmall,
            ),
            child: SizedBox(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: PaginatedListViewWidget(
                  scrollController: _scrollController,
                  totalSize: aiChatBotController.conversationModel!.totalSize,
                  offset: aiChatBotController.conversationModel!.offset,
                  onPaginate: (int? offset) async {
                    await aiChatBotController.getConversationList(offset!);
                  },
                  productView: ListView.builder(
                    itemCount: aiChatBotController.conversationModel!.data!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final conversation = aiChatBotController.conversationModel!.data![index];
                      final bool deleting = conversation.id != null
                          && aiChatBotController.isDeleting(conversation.id!);
                      return AiChatConversationCardWidget(
                        conversation: conversation,
                        isDeleting: deleting,
                        onTap: deleting ? null : () => Get.toNamed(RouteHelper.getAiChatDetailsScreen(
                          conversationId: conversation.id,
                          title: conversation.title,
                        )),
                        onDelete: conversation.id == null ? null : () => _confirmDelete(conversation),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
