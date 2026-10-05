import 'package:flutter/material.dart';

import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class SearchSuggestionListTile extends StatelessWidget {
  const SearchSuggestionListTile({
    super.key,
    this.image,
    this.leading,
    this.onTap,
    this.title,
    this.titleWidget,
    this.trailingWidget,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final String? image;
  final Widget? leading;
  final VoidCallback? onTap;
  final String? title;
  final Widget? titleWidget;
  final Widget? trailingWidget;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: Dimensions.paddingSmall),
            ],

            Expanded(
              child: titleWidget ??
                  Text(
                    title ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),

            SizedBox(width: Dimensions.paddingSmall),

            trailingWidget ??
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: context.iconNeutralLight,
                ),
          ],
        ),
      ),
    );
  }
}