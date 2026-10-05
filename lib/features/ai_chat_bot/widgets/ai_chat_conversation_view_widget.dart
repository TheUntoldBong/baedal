import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/controllers/ai_chat_bot_controller.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/domain/models/ai_chat_message_model.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_message_bubble_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_suggestion_chips_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatConversationViewWidget extends StatefulWidget {
  final int? conversationId;
  final String? initialMessage;

  final ValueChanged<int>? onConversationCreated;

  const AiChatConversationViewWidget({
    super.key,
    required this.conversationId,
    this.initialMessage,
    this.onConversationCreated,
  });

  @override
  State<AiChatConversationViewWidget> createState() => _AiChatConversationViewWidgetState();
}

class _AiChatConversationViewWidgetState extends State<AiChatConversationViewWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  int? _activeConversationId;

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    _initCall();
  }

  void _initCall() {
    final controller = Get.find<AiChatBotController>();
    if (_activeConversationId != null) {
      controller.getMessages(_activeConversationId!, 1, firstLoad: true);
    } else {
      controller.clearMessages();
    }
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _inputController.text = widget.initialMessage!;
        controller.toggleSendButtonActivity(true);
        _onSendPressed();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    final String message = _inputController.text.trim();
    if (message.isEmpty) {
      showCustomSnackBar('write_something'.tr);
      return;
    }
    _inputController.clear();
    _inputFocusNode.unfocus();
    final controller = Get.find<AiChatBotController>();
    controller.toggleSendButtonActivity(false);

    await controller.sendMessage(
      message: message,
      conversationId: _activeConversationId,
      onConversationIdAssigned: (id) {
        _activeConversationId = id;
        widget.onConversationCreated?.call(id);
      },
    );

    controller.getConversationList(1, reload: true);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiChatBotController>(builder: (controller) {
      return Column(children: [

        Expanded(
          child: Builder(builder: (_) {
            final bool sending = controller.isSendingMessage;
            final List<AiChatMessage> messages = List<AiChatMessage>.from(
              controller.messageModel?.messages ?? const <AiChatMessage>[],
            );
            messages.sort((a, b) {
              final DateTime aTime = DateTime.tryParse(a.createdAt ?? '')?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0);
              final DateTime bTime = DateTime.tryParse(b.createdAt ?? '')?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });
            final bool hasMessages = messages.isNotEmpty;

            if (controller.messageModel == null && _activeConversationId != null && !sending) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!hasMessages && !sending) {
              if (_activeConversationId == null) {
                return AiChatWelcomeViewWidget(
                  onSuggestionTap: (text) {
                    _inputController.text = text;
                    _onSendPressed();
                  },
                );
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingLarge),
                  child: Text(
                    'no_message_found'.tr,
                    style: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSmall),
              child: PaginatedListViewWidget(
                scrollController: _scrollController,
                reverse: true,
                totalSize: controller.messageModel?.totalSize ?? messages.length,
                offset: controller.messageModel?.offset ?? 1,
                onPaginate: (int? offset) async {
                  if (_activeConversationId != null) {
                    await controller.getMessages(_activeConversationId!, offset!);
                  }
                },
                productView: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  reverse: true,
                  padding: EdgeInsets.zero,
                  itemCount: messages.length + (sending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (sending && index == 0) {
                      return const AiChatTypingBubbleWidget();
                    }
                    final int messageIndex = sending ? index - 1 : index;
                    return AiChatMessageBubbleWidget(message: messages[messageIndex]);
                  },
                ),
              ),
            );
          }),
        ),

        AiChatInputBarWidget(
          controller: _inputController,
          focusNode: _inputFocusNode,
          isSending: controller.isSendingMessage,
          isActive: controller.isSendButtonActive && controller.canSend,
          onChanged: (value) => controller.toggleSendButtonActivity(value.trim().isNotEmpty),
          onSubmit: _onSendPressed,
        ),

      ]);
    });
  }
}

const double _composerHeight = 48;

class AiChatInputBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isSending;
  final bool isActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  const AiChatInputBarWidget({
    super.key,
    required this.controller,
    this.focusNode,
    required this.isSending,
    required this.isActive,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingDefault,
          vertical: Dimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: context.surfaceContainer,
          boxShadow: [BoxShadow(color: context.shadow, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [

          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: _composerHeight),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                border: Border.all(
                  color: context.outlineVariant,
                  width: 0.6,
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                textCapitalization: TextCapitalization.sentences,
                style: context.body.defaultSize.regular,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                minLines: 1,
                inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingMedium),
                  hintText: 'ask_anything'.tr,
                  hintStyle: context.body.defaultSize.regular.overrideWith(color: context.textBaseMedium),
                ),
                onSubmitted: (_) => isSending ? null : onSubmit(),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSmall),

          InkWell(
            onTap: isSending ? null : onSubmit,
            canRequestFocus: false,
            customBorder: const CircleBorder(),
            child: Container(
              height: _composerHeight, width: _composerHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isActive && !isSending)
                    ? context.primary
                    : context.bgNeutralMedium,
              ),
              alignment: Alignment.center,
              child: isSending
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
            ),
          ),

        ]),
      ),
    );
  }
}

class AiChatWelcomeViewWidget extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;
  const AiChatWelcomeViewWidget({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingLarge,
        vertical: Dimensions.paddingExtraLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            height: 110, width: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.primary.withValues(alpha: 0.2),
                  context.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 56,
              color: context.primary,
            ),
          ),
          const SizedBox(height: Dimensions.paddingLarge),

          Text(
            'ask_anything'.tr,
            style: context.heading.large.strong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.padding2xSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingLarge),
            child: Text(
              'start_a_new_conversation_with_ai'.tr,
              style: context.body.small.regular.overrideWith(color: context.textBaseMedium),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingExtraLarge),

          AiChatSuggestionChipsWidget(onSuggestionTap: onSuggestionTap),

        ],
      ),
    );
  }
}
