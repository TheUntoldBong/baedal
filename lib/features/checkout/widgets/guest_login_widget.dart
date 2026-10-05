import 'package:stackfood_multivendor/util/color_resources.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/common/widgets/custom_tool_tip.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class GuestLoginWidget extends StatefulWidget {
  final JustTheController loginTooltipController;
  final Function()? onTap;
  const GuestLoginWidget({super.key, required this.loginTooltipController, this.onTap});

  @override
  State<GuestLoginWidget> createState() => _GuestLoginWidgetState();
}

class _GuestLoginWidgetState extends State<GuestLoginWidget> {

  final loginController = JustTheController();

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: context.width,
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: context.shadow, spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingLarge : Dimensions.paddingSmall, vertical: Dimensions.paddingSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text('wants_to_unlock_more_features'.tr, style: context.subHeading.defaultSize.medium),
          const SizedBox(height: Dimensions.padding2xSmall),

          SizedBox(
            height: isDesktop ? 30 : 20,
            child: TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: widget.onTap,
              child: Text('click_here_to_login'.tr, style: context.subHeading.small.regular.overrideWith(color: context.primary)),
            ),
          ),

        ]),

        CustomToolTip(
          message: 'login_to_manage_your_orders_and_enjoy_additional_benefits'.tr,
          preferredDirection: AxisDirection.down,
        ),

      ]),
    );
  }
}
