import 'package:stackfood_multivendor/features/pro/domain/models/pro_faq_model.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ProFaqWidget extends StatefulWidget {
  final List<ProFaqModel>? faqList;
  const ProFaqWidget({super.key, required this.faqList});

  @override
  State<ProFaqWidget> createState() => _ProFaqWidgetState();
}

class _ProFaqWidgetState extends State<ProFaqWidget> {
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final List<ProFaqModel> items = widget.faqList?.where((faq) => faq.question != null && faq.question!.trim().isNotEmpty).toList() ?? [];
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('frequently_asked_questions'.tr, style: context.heading.large.strong),
        const SizedBox(height: Dimensions.paddingSmall),
        ...items.asMap().entries.map((e) => _buildFaqItem(context, e.key, e.value)),
      ],
    );
  }

  Widget _buildFaqItem(BuildContext context, int index, ProFaqModel item) {
    final bool isExpanded = _expandedIndex == index;
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expandedIndex = isExpanded ? -1 : index),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingDefault),
            child: Row(
              children: [
                Expanded(child: Text(item.question ?? '', style: context.subHeading.defaultSize.medium)),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: context.textBaseMedium,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingDefault),
            child: Text(item.answer ?? '', style: context.body.small.regular.overrideWith(color: context.textBaseMedium)),
          ),
        Divider(color: context.outlineVariant, height: 1),
      ],
    );
  }
}
