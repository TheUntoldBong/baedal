import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_conversation_view_widget.dart';

class AiChatDetailsScreen extends StatelessWidget {
  final int? conversationId;
  final String? title;
  final String? initialMessage;
  const AiChatDetailsScreen({
    super.key,
    required this.conversationId,
    this.title,
    this.initialMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: title?.isNotEmpty == true ? title! : 'ai_assistant'.tr),
      body: AiChatConversationViewWidget(
        conversationId: conversationId,
        initialMessage: initialMessage,
      ),
    );
  }
}
